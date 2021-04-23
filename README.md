# cvp-in-gcp

Templates to launch fully-functional CVP clusters in GCP.

<!-- vscode-markdown-toc -->
* 1. [TLDR](#TLDR)
* 2. [Requisites](#Requisites)
	* 2.1. [terraform >= 0.13](#terraform0.13)
	* 2.2. [gcloud client](#gcloudclient)
	* 2.3. [ansible](#ansible)
* 3. [Quickstart](#Quickstart)
* 4. [Variables](#Variables)
		* 4.1. [Mandatory](#Mandatory)
		* 4.2. [Optional](#Optional)
* 5. [Examples](#Examples)
	* 5.1. [Using command-line variables:](#Usingcommand-linevariables:)
	* 5.2. [Using a `.tfvars` file](#Usinga.tfvarsfile)
* 6. [Removing the environment](#Removingtheenvironment)
* 7. [Other Notes](#OtherNotes)
* 8. [Bugs and Limitations](#BugsandLimitations)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='TLDR'></a>TLDR
Install terraform, configure gcloud and use one of the provided `.tfvars` examples.

> **_NOTE_**: If you get the `The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created.` error message, you didn't use the `-target module.cvp_cluster` parameter. See [Other Notes](#OtherNotes) for more info.

##  2. <a name='Requisites'></a>Requisites
###  2.1. <a name='terraform0.13'></a>terraform >= 0.13
This module should work with any terraform version above 0.13. You can [download it from the official website][terraform-download].

Terraform is distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`.

###  2.2. <a name='gcloudclient'></a>gcloud client
You must have the Google Cloud SDK installed and authenticated. For installation details please see [here][gcloud-install].

We suggest that you create a profile and authenticate the cli using these steps. Feel free to change `cvp-profile` to whatever profile name you prefer:

1. Initialize your gcloud profile
```bash
$ gcloud config configurations create cvp-profile
$ gcloud config configurations activate cvp-profile
$ gcloud init 
```
- Choose [1] Re-initialize this configuration [arista-cvp] with new settings
- Select an existing project from the list or create a new project if desired. Clusters will be launched in this project.
- Choose `Y` when asked whether to configure a default Compute Region and Zone
- You can select any region. For the purposes of this guide we'll use option `8` (`us-central1-a`)


2. Get API credentials for terraform
```bash
$ gcloud auth application-default login
```

###  2.3. <a name='ansible'></a>ansible
You must have ansible installed for provisioning to work. You can check installation instructions [here][ansible-install].

##  3. <a name='Quickstart'></a>Quickstart
These steps assume that you created a profile following the steps in the [gcloud client](#gcloudclient) section:
- Activate the profile:

```bash
$ gcloud config configurations activate cvp-profile
```

- Initialize terraform (only needed on the first run): 

```bash
$ terraform init
```

- Edit the `examples/one-node-cvp-deployment.tfvars` file and replace with the desired values.
```
$ vi examples/one-node-cvp-deployment.tfvars
```

- Plan your bootstrap run: 

```bash
$ terraform plan -out=plan.out -var-file=examples/one-node-cvp-deployment.tfvars -target module.cvp_cluster
```

- Review your plan
- Apply the generated plan: 

```bash
terraform apply plan.out
```

> At this point your infrastructure should be running on GCP, but CVP hasn't been provisioned yet.

- Plan your full provisioning run:

```bash
$ terraform plan -out=plan.out -var-file=examples/one-node-cvp-deployment.tfvars
```

- Review your plan
- Apply the generated plan: 

```bash
terraform apply plan.out
```

- Go have a coffee. At this point CVP should be starting in your instance and may take some time to finish bringing all services up. You can ssh into your cvp instances with the displayed `cvp_cluster_ssh_user` and `cvp_cluster_nodes_ips` to check progress.

##  4. <a name='Variables'></a>Variables
Mandatory variables will be asked at runtime unless specified on the command line or using a [.tfvars file](terraform-tfvars), which is recommended in most cases.

####  4.1. <a name='Mandatory'></a>Mandatory
- **gcp_project_id**: The name of the GCP Project where all resources will be launched. May also be obtained from the `GOOGLE_PROJECT` environment variable.
- **gcp_region**: The region in which all GCP resources will be launched.
- **gcp_zone**: The zone in which all GCP resources will be launched. Must be a valid zone within the desired `gcp_region`.
- **cvp_cluster_name**: The name of the CVP cluster
- **cvp_cluster_size**: The number of nodes in the CVP cluster. Must be 1 or 3 nodes.
- **cvp_download_token**: Arista Portal token used to download CVP.

####  4.2. <a name='Optional'></a>Optional
- **gcp_network**: The network in which clusters will be launched. Leaving this blank will create a new network.
- **cvp_cluster_vmtype**: The type of instances used for CVP
- **cvp_cluster_public_management**: Whether the cluster UI and SSH ports (https/ssh) is publically accessible over the internet. Defaults to `false`.
- **cvp_cluster_vm_admin_user**: Admin user to connect to instances in the CVP cluster using ssh. Should be used in conjunction with `cvp_cluster_vm_key`. Defaults to `cvpsshadmin`.
- **cvp_cluster_vm_key**: Path to the public SSH key used to access instances in the CVP cluster using ssh as the `cvp_cluster_vm_admin_user` user.
- **cvp_cluster_remove_disks**: Whether data disks created for the instances will be removed when destroying them. Defaults to `false`.
- **cvp_cluster_vm_private_key**: Private SSH key used to access instances in the CVP cluster.
- **cvp_cluster_vm_password**: Password used to access instances in the CVP cluster.
- **cvp_version**: CVP version to install on the cluster.
- **cvp_install_size**: CVP installation size. The module will try to guess the best installation size based on the vm size if not provided. Valid values are `demo`, `small`, `production` and `prod_wifi`.

##  5. <a name='Examples'></a>Examples
###  5.1. <a name='Usingcommand-linevariables:'></a>Using command-line variables:

```bash
$ terraform apply -var gcp_project_id=myproject -var cvp_cluster_name=mycluster -var cvp_cluster_size=1 -var gcp_region=us-central1 -var gcp_zone=a -target module.cvp_cluster # first apply only
$ terraform apply -var gcp_project_id=myproject -var cvp_cluster_name=mycluster -var cvp_cluster_size=1 -var gcp_region=us-central1 -var gcp_zone=a # subsequent applies
```

###  5.2. <a name='Usinga.tfvarsfile'></a>Using a `.tfvars` file
**Note**: Before running this please replace the `gcp_project_id` variable in the provided example file with the correct name of your project.

```bash
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars -target module.cvp_cluster # first apply only
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars # subsequent applies
```

##  6. <a name='Removingtheenvironment'></a>Removing the environment
In order to remove the environment you launched you can run the following command:

```bash
$ terraform destroy -var-file=examples/one-node-cvp-deployment.tfvars
```

This will remove everything except data disks (and networks when using pre-existing ones) from the GCP project. Please read [other notes](#OtherNotes) below for more info.

##  7. <a name='OtherNotes'></a>Other Notes
- **Data disks**: Data disks will **not** be removed when destroying the environment unless `cvp_cluster_remove_disks` is set to `true`. Make sure to remove them manually when they're no longer needed.

- **target module.cvp_cluster**: Due to limitations in terraform we need to run it twice when creating the environment for the first time. This is due to the need of referencing instances that are created by the Instance Group Manager when provisioning the cluster, which can only be done after the environment is actually created. <br />&nbsp;<br />The first run should use the parameter `-target module.cvp_cluster` so that only the cluster creation takes place, ignoring the provisioning part. Once the cluster is running the parameter shouldn't be used anymore, and subsequent runs will both adjust cluster settings and do all necessary provisioning steps.

##  8. <a name='BugsandLimitations'></a>Bugs and Limitations
- **Only single-node clusters are supported for now**. Support for multi-node clusters will be added in future releases.
- Resizing clusters is not supported at this time.
- This module connects to the instance using the `root` user instead of the declared user for provisioning due to limitations in the base image that's being used. If you know your way around terraform and understand what you're doing, this behaviour can be changed by editing the `modules/cvp-provision/main.tf` file.
- CVP installation size auto-discovery only works for custom instances at this time.


[ansible-install]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-the-ansible-community-package
[gcloud-install]: https://cloud.google.com/sdk/docs/install
[terraform-download]: https://www.terraform.io/downloads.html
[terraform-tfvars]: https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files
[terraform-no-project]: https://github.com/hashicorp/terraform-provider-google/issues/4856