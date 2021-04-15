# cvp-in-gcp

Templates to launch fully-functional CVP clusters in GCP.

<!-- vscode-markdown-toc -->
* 1. [TLDR](#TLDR)
* 2. [Requisites](#Requisites)
	* 2.1. [terraform >= 0.13](#terraform0.13)
	* 2.2. [gcloud client](#gcloudclient)
* 3. [Running terraform](#Runningterraform)
	* 3.1. [Variables](#Variables)
		* 3.1.1. [Mandatory](#Mandatory)
		* 3.1.2. [Optional](#Optional)
* 4. [Examples](#Examples)
	* 4.1. [Using command-line variables:](#Usingcommand-linevariables:)
	* 4.2. [Using a `.tfvars` file:](#Usinga.tfvarsfile:)
* 5. [Other Notes](#OtherNotes)
* 6. [Bugs](#Bugs)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='TLDR'></a>TLDR
Install terraform, configure gcloud and use the `.tfvars` example.

##  2. <a name='Requisites'></a>Requisites
###  2.1. <a name='terraform0.13'></a>terraform >= 0.13
This module should work with any terraform version above 0.13. You can [download it from the official website][terraform-download].

Terraform is distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`.

###  2.2. <a name='gcloudclient'></a>gcloud client
You must have the Google Cloud SDK installed and authenticated. For installation details please see [here][gcloud-install].

We suggest that you create a profile and authenticate the cli using these steps:

```bash
$ gcloud config configurations create cvp-profile
$ gcloud config configurations activate cvp-profile
$ gcloud init
$ gcloud auth application-default login
```

Feel free to change `cvp-profile` to whatever profile name you prefer.

##  3. <a name='Runningterraform'></a>Running terraform
These steps assume that you created a profile following the steps in the [gcloud client](#gcloudclient) section:
- Activate the profile:

```bash
$ gcloud config configurations activate cvp-profile
```

- Export the [name of the GCP project](terraform-no-project): 

```bash
$ export GOOGLE_PROJECT=your_project_name
```

- Initialize terraform (only needed on the first run): 

```bash
$ terraform init
```

- Plan your run: 

```bash
$ terraform plan -out=plan.out
```

- Review your plan
- Apply the generated plan: 

```bash
terraform apply plan.out
```

###  3.1. <a name='Variables'></a>Variables
Mandatory variables will be asked at runtime unless specified on the command line or using a [.tfvars file](terraform-tfvars)

####  3.1.1. <a name='Mandatory'></a>Mandatory
- **gcp_project_id**: The name of the GCP Project where all resources will be launched. May also be obtained from the `GOOGLE_PROJECT` environment variable.
- **gcp_region**: The region in which all GCP resources will be launched.
- **gcp_zone**: The zone in which all GCP resources will be launched. Must be a valid zone within the desired `gcp_region`.
- **cvp_cluster_name**: The name of the CVP cluster
- **cvp_cluster_size**: The number of nodes in the CVP cluster. Must be 1 or 3 nodes.

####  3.1.2. <a name='Optional'></a>Optional
- **gcp_network**: The network in which clusters will be launched. Leaving this blank will create a new network.
- **cvp_cluster_vmtype**: The type of instances used for CVP
- **cvp_cluster_public_management**: Whether the cluster UI and SSH ports (https/ssh) is publically accessible over the internet. Defaults to `false`.
- **cvp_cluster_vm_key**: Path to the public SSH key used to access instances in the CVP cluster.
- **cvp_cluster_remove_disks**: Whether data disks created for the instances will be removed when destroying them. Defaults to `false`.

##  4. <a name='Examples'></a>Examples
###  4.1. <a name='Usingcommand-linevariables:'></a>Using command-line variables:

```bash
$ terraform apply -var gcp_project_id=myproject -var cvp_cluster_name=mycluster -var cvp_cluster_size=1 -var gcp_region=us-central1 -var gcp_zone=a
```

###  4.2. <a name='Usinga.tfvarsfile:'></a>Using a `.tfvars` file:
**Note**: Before running this please replace the `gcp_project_id` variable in the provided example file with the correct name of your project.

```
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars
```

##  5. <a name='OtherNotes'></a>Other Notes
- Data disks will **not** be removed when destroying the environment unless `cvp_cluster_remove_disks` is set to `true`. Make sure to remove them manually when they're no longer needed.

##  6. <a name='Bugs'></a>Bugs
- [Running the module without explicitely setting a project will fail][terraform-no-project]

[gcloud-install]: https://cloud.google.com/sdk/docs/install
[terraform-download]: https://www.terraform.io/downloads.html
[terraform-tfvars]: https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files
[terraform-no-project]: https://github.com/hashicorp/terraform-provider-google/issues/4856