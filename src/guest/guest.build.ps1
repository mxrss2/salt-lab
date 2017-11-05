$vendorDirectory = resolve-path ../vendor

. $vendorDirectory/psMustache/psMustache.ps1
$provisioner_work = "Invoke-Build _genConfig, _mountKubeStorage"


# Synopsis: Create the Lab
task CreateLab {
    minikube start
    Invoke-Build _mountKubeStorage
    $env:MINIKUBE_IP = $(minikube ip)
    $env:SALT_MASTER_TO_CONFIGURE = $env:MINIKUBE_IP

    'Creating Provisioner and Job Files'
    Invoke-Expression $provisioner_work
    'Creating Lab!'
    vagrant up 
    'Reloading Configuration After Hostname Change'
    vagrant reload
}

# Synopsis: Restore the lab
task RestoreLab  {
    'Restoring Lab'
    Invoke-Build DestroyLab, CreateLab
} 

# Synopsis: Destroy the Lab
task DestroyLab {
    'Destroying Lab'
    minikube delete
    vagrant destroy -f
}

# Synopsis: Remote Powershelll into web 1
task RemoteShell-Web1 { 
    'Remoting into Web 1'
    vagrant powershell web-1
}

# Synopsis: Remote Powershelll into web 2
task RemoteShell-Web2 { 
    'Remoting into Web 2'
    vagrant powershell web-2
}


# Synopsis: Remote SSH into proxy
task RemoteShell-Proxy { 
    'Remoting into proxy'
    vagrant ssh proxy
}


# Synopsis: Parallel support for uping the vagrant machines -- EXPERIMENTAL!
task Parallel-CreateLab {
    'Creating Minikube'
    minikube start
    
    $env:MINIKUBE_IP = $(minikube ip)
    Invoke-Expression $provisioner_work 
    $env:SALT_MASTER_TO_CONFIGURE = $env:MINIKUBE_IP


    'Creating your vagrant setup and provisioning'
    @("web-1", "web-2", "proxy") | % {
        $scriptBlock = {
            param($pipelinePassIn, $TEST)
            cd $TEST
            &vagrant up $pipelinePassIn
        }

        Start-Job $scriptBlock -ArgumentList @($_, $PSScriptRoot)

    }

    Get-Job

    #Wait for completion
    While (Get-Job -State "Running"){
        Start-Sleep 3
    }

    invoke-build _cleanUpJobs

}

# Synopsis: Destroy the Lab in a parallel fashion -- *EXPERIMENTAL*
task Parallel-DestroyLab {
    'Destroying Lab'
    

    
        $deleteMinikube = {
            param($execDir)
            cd $execDir
            minikube delete
        }

        $vagrantDelete = {
            param($execDir)
            cd $execDir
            &vagrant destroy -f
        }

        Start-Job $deleteMinikube -ArgumentList $PSScriptRoot
        Start-Job $vagrantDelete -ArgumentList $PSScriptRoot
    
    Get-Job

    #Wait for completion
    While (Get-Job -State "Running"){
        Start-Sleep 3
    }

    invoke-build _cleanUpJobs
    
}

# Synopsis: Restore the lab using our parallel functions *EXPERIMENTAL*
task Parallel-RestoreLab  {
    'Restoring Lab'
    Invoke-Build Parallel-DestroyLab, Parallel-CreateLab
} 


task _mountKubeStorage {
    "Mounting Storage in $PWD\..\saltmaster"
    &vboxmanage.exe sharedfolder add minikube --hostpath "$(Resolve-Path $PWD\..\saltmaster)" --name vm-salt-lab --transient
    &kubectl apply -f "$PWD\..\saltmaster\_generated\mount-filesystem-job.yml"
}


task _cleanUpJobs {
    Get-Job | Receive-Job
    get-job | % { Remove-Job $_ }
}

task _genConfig {
    
    $ip = $env:MINIKUBE_IP
    Invoke-Template @{minikube_ip=$ip} $(cat ../templates/SaltConfigDeployment.tpl.yml -raw) > ../saltmaster/_generated/SaltConfigDeployment.yml
    Invoke-Template @{minikube_ip=$ip} $(cat "../templates/mount-filesystem-job.tpl.yml" -raw) > ../saltmaster/_generated/mount-filesystem-job.yml
}
