# Synopsis: Create the Lab
task CreateLab {
    minikube start
    $ip = $(minikube ip)
    $env:SALT_MASTER_TO_CONFIGURE = $ip
    'Creating Lab!'
    vagrant up --parallel
    'Reloading Configuration After Hostname Change'
    vagrant reload --parallel
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
    $ip = $(minikube ip)
    $env:SALT_MASTER_TO_CONFIGURE = $ip


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



task _cleanUpJobs {
    Get-Job | Receive-Job
    get-job | % { Remove-Job $_ }
}
