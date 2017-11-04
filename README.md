# Server Engineer Developer Kit (SEDK)

## About

This repository holds a developer kit for getting started with creating states for SSP development resources, this is an evolving 
resource that can be used by anyone employed at Assurant. This part of the kit contains the Vagrant file for local development

>> The Lab will create its self using the tooling, it should be a zero touch experience once you run the `requirements.cmd` and 
>> `develop.cmd` module. Everything should load and should require very minimal configuration.


## How Does This Work?

Well the lab uses a few technolgies like Vagrant and Minikube to create a fully working and useable lab. The lab will create the following, two windows 2012 server core nodes and one load balancer. Minikube will create a one node Kuberntes cluster which will house
the Salt Server. The image is pulled off the public internete from http://hub.docker.com but it was baked in house. The Server only contains a docker image with the following recipe.

If you look at the docs folder in the root a PDF and visio document describe what the lab looks like. I am using GitFS to store the state to show what a fully baked out implementation will look like. The branches are used so that changes are migrated gradullally out. 

Source: (Saltstack-Image)[https://github.com/mxrss2/saltstack-image]


## Who Maintains This?

The main maintainer of this repository is the Server Engineering Group at SSP in Collaboration wtih the SSP SRE teams.

## Who Should Use This?

This kit can be used by anyone in the organization, From Developers to Operations Folks to QA Engineers. 

## Who Should Commit Back To Us?

Anyone, we take pull requests and you are more than free to suggest and add to the SEDK. 

## What Tools Are Installed?

`requirements.cmd` will install the following.

* Chocolatey (Windows Package Management)
* git and git.install packages
* invoke-build (Powershell Module)
* Kubernetes CLI (kubectl)
* Vagrant
* VirtualBox
* Minikube


###  What is Vagrant?

>> Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team.

Read more at [Why Vagrant?](https://www.vagrantup.com/intro/index.html)

## How To Use?

>> Because of the Home Drive being on the U:/ Drive it is best to run minikube and vagrant as administrator. The batch files should load as Admin.

1. Run `requirements.cmd` 
2. Run `Develop.cmd`
3. The following will load the developer experience.
4. Use the `Invoke-Build ?`
    1. This will get you a list of allowed tasks that you can run
5. To start the lab type `invoke-build CreateLab`
5. To Shut down the Guest use `Invoke-Build DestroyLab`  

## **Experimental Support** Parallel Jobs Using Jobs in Powershell

Added support for Experimental support for using parallel tasks to spin up the environment. Usually the full provision takes about 7 minutes but if you use `Parallel-` in front of the task it will bring down the time by a factor of half. Most runs with SSD's take in the neighborhood of 3 minutes. 

## Release Notes

The following contains the releas notes for this lab.


### Version 1.0 (Alpha Centari)

* Inital Features
    * Created image for SaltStack that works through Minikube
    * Create winodws vagrant image for win2k12r2-Core
    * Created `requirements.cmd` which will install all dependencies
    * Created Salt States that are used on first run for Minions
    * Created `Invoke-Build` script that is used for orchestrating Minikube and Vagrant
    * Added parallel extensions to `invoke-build`

