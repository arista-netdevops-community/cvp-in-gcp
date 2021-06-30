# cvp-in-gcp

Templates to launch fully functional CVP clusters in GCP.

<!-- vscode-markdown-toc -->
* 1. [TLDR](#TLDR)
* 2. [Requisites](#Requisites)
	* 2.1. [terraform >= 0.13](#terraform0.13)
	* 2.2. [Google Cloud SDK](#GoogleCloudSDK)
	* 2.3. [ansible](#ansible)
* 3. [Quickstart](#Quickstart)
* 4. [Adding EOS devices](#AddingEOSdevices)
* 5. [Variables](#Variables)
* 6. [Examples](#Examples)
	* 6.1. [Using a `.tfvars` file](#Usinga.tfvarsfile)
	* 6.2. [Using command-line variables:](#Usingcommand-linevariables:)
* 7. [Removing the environment](#Removingtheenvironment)
* 8. [Bugs and Limitations](#BugsandLimitations)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='TLDR'></a>TLDR
Install terraform, ansible, gcloud SDK and use one of the provided `.tfvars` examples.

##  2. <a name='Requisites'></a>Requisites
###  2.1. <a name='terraform0.13'></a>terraform >= 0.13
This module is tested with terraform `1.0.1`, but should work with any terraform version above 0.13. You can [download it from the official website][terraform-download].

Terraform is distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`.

###  2.2. <a name='GoogleCloudSDK'></a>Google Cloud SDK
You must have the Google Cloud SDK installed and authenticated. For installation details please see [here][gcloud-install]. If asked `Optional. Use the install script to add Cloud SDK tools to your PATH` reply `Yes`

We suggest that you create a profile and authenticate the cli using these steps. Feel free to change `cvp-profile` to whatever profile name you prefer:

1. Initialize your gcloud profile
```bash
$ gcloud config configurations create cvp-profile
$ gcloud config configurations activate cvp-profile
$ gcloud init 
```
- Choose [1] Re-initialize this configuration [arista-cvp] with new settings
- Select an existing project from the list or create a new project if desired. Clusters will be launched in this project. If you're trying to create a project and receives an error saying `No permission to create project in organization` you'll need to check your permissions with your cloud administrator or use an existing project.
- Choose `Y` when asked whether to configure a default Compute Region and Zone
- You can select any region. For this guide, we'll use option `8` (`us-central1-a`)


2. Get API credentials for terraform
```bash
$ gcloud auth application-default login
```

###  2.3. <a name='ansible'></a>ansible
You must have ansible installed for provisioning to work. You can check installation instructions [here][ansible-install].

##  3. <a name='Quickstart'></a>Quickstart
These steps assume that you created a profile following the steps in the [gcloud client](#gcloudclient) section. You must also be in the project's directory (`cvp-in-gcp`):
- Activate the profile:

```bash
$ gcloud config configurations activate cvp-profile
```

- Initialize Terraform (only needed on the first run):

```bash
$ terraform init
```

- Edit the `examples/one-node-cvp-deployment.tfvars` file and replace with the desired values.
```
$ vi examples/one-node-cvp-deployment.tfvars
```

- Plan your full provisioning run:

```bash
$ terraform plan -out=plan.out -var-file=examples/one-node-cvp-deployment.tfvars
```

- Review your plan
- Apply the generated plan: 

```bash
terraform apply plan.out
```

- Go have a coffee. At this point, CVP should be starting in your instance and may take some time to finish bringing all services up. You can ssh into your cvp instances with the displayed `cvp_cluster_ssh_user` and `cvp_cluster_nodes_ips` to check progress.

##  4. <a name='AddingEOSdevices'></a>Adding EOS devices
If devices are in a network that can't be reached by CVP they need to be added by configuring TerminAttr on the devices themselves (similar to any setup behind NAT). At the end of the
terraform run a suggested TerminAttr configuration line will be displayed containing the appropriate `ingestgrpcurl` and `ingestauth` parameters:

```
Provisioning complete. To add devices use the following TerminAttr configuration:
exec /usr/bin/TerminAttr -ingestgrpcurl=34.71.81.254:9910 -cvcompression=gzip -ingestauth=key,JkqAGsEyGPmUZ3X0 -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent -ingestvrf=default -taillogs
```

The `exec` configuration can be copy-pasted and should be usable in most scenarios.

##  5. <a name='Variables'></a>Variables
Mandatory variables are asked at runtime unless specified on the command line or using a [.tfvars file](terraform-tfvars), recommended in most cases.
<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

##  6. <a name='Examples'></a>Examples
<!-- ###  5.1. <a name='UsingtheDockerimage'></a>Using the Docker image
The docker image contains all dependencies pre-installed. It uses the same general syntax as the `.tfvars` method:

```bash
$ docker run --rm -ti -v $HOME/.ssh:/cvp/.ssh -v $(pwd):/cvp test apply -var-file=examples/one-node-cvp-deployment.tfvars
```

Some directories can be mounted if you wish to use pre-existing configuration:
- **-v $HOME/.ssh:/cvp/.ssh**: Path to existing SSH keys.
- **-v $HOME/.config/gcloud:/cvp/.gcloud**: Path to an existing gcloud configuration

If those directories are not mounted new configurations will be generated.
-->

###  6.1. <a name='Usinga.tfvarsfile'></a>Using a `.tfvars` file
**Note**: Before running this please replace the `gcp_project_id` variable in the provided example file with the correct name of your project and `cvp_download_token` with your Arista Portal token.

```bash
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars
```

###  6.2. <a name='Usingcommand-linevariables:'></a>Using command-line variables:

```bash
$ terraform apply -var gcp_project_id=myproject -var gcp_region=us-central1 -var gcp_zone=a -var cvp_cluster_name=my-cvp-cluster -var cvp_cluster_size=1 -var cvp_cluster_public_management=true -var cvp_cluster_vm_key="~/.ssh/id_rsa.pub" -var cvp_cluster_vm_private_key="~/.ssh/id_rsa" -var cvp_download_token="PLACE_YOUR_PORTAL_TOKEN_HERE"
```

##  7. <a name='Removingtheenvironment'></a>Removing the environment
In order to remove the environment you launched you can run the following command:

```bash
$ terraform destroy -var-file=examples/one-node-cvp-deployment.tfvars
```

This command removes everything from the GCP project.

##  8. <a name='BugsandLimitations'></a>Bugs and Limitations
- Resizing clusters is not supported at this time.
- This module connects to the instance using the `root` user instead of the declared user for provisioning due to limitations in the base image that's being used. If you know your way around terraform and understand what you're doing, this behavior can be changed by editing the `modules/cvp-provision/main.tf` file.
- CVP installation size auto-discovery only works for custom instances at this time.


[ansible-install]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-the-ansible-community-package
[gcloud-install]: https://cloud.google.com/sdk/docs/install
[terraform-download]: https://www.terraform.io/downloads.html
[terraform-tfvars]: https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files