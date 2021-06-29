# cvp-in-gcp

Templates to launch fully functional CVP clusters in GCP.

<!-- vscode-markdown-toc -->
* 1. [TLDR](#TLDR)
* 2. [Requisites](#Requisites)
	* 2.1. [terraform >= 0.13](#terraform0.13)
	* 2.2. [gcloud client](#gcloudclient)
	* 2.3. [ansible](#ansible)
* 3. [Quickstart](#Quickstart)
* 4. [Adding EOS devices](#AddingEOSdevices)
* 5. [Variables](#Variables)
		* 5.1. [Mandatory](#Mandatory)
		* 5.2. [Optional](#Optional)
* 6. [Examples](#Examples)
	* 6.1. [Using a `.tfvars` file](#Usinga.tfvarsfile)
	* 6.2. [Using command-line variables:](#Usingcommand-linevariables:)
* 7. [Removing the environment](#Removingtheenvironment)
* 8. [Other Notes](#OtherNotes)
* 9. [Bugs and Limitations](#BugsandLimitations)

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
<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cvp_cluster_centos_version"></a> [cvp\_cluster\_centos\_version](#input\_cvp\_cluster\_centos\_version) | The Centos version used by CVP instances. | `string` | `null` | no |
| <a name="input_cvp_cluster_name"></a> [cvp\_cluster\_name](#input\_cvp\_cluster\_name) | The name of the CVP cluster | `string` | n/a | yes |
| <a name="input_cvp_cluster_public_eos_communitation"></a> [cvp\_cluster\_public\_eos\_communitation](#input\_cvp\_cluster\_public\_eos\_communitation) | Whether the ports used by EOS devices to communicate to CVP are publically accessible over the internet. | `bool` | `false` | no |
| <a name="input_cvp_cluster_public_management"></a> [cvp\_cluster\_public\_management](#input\_cvp\_cluster\_public\_management) | Whether the cluster management interface (https/ssh) is publically accessible over the internet. | `bool` | `false` | no |
| <a name="input_cvp_cluster_remove_disks"></a> [cvp\_cluster\_remove\_disks](#input\_cvp\_cluster\_remove\_disks) | Whether data disks created for the instances will be removed when destroying them. | `bool` | `false` | no |
| <a name="input_cvp_cluster_size"></a> [cvp\_cluster\_size](#input\_cvp\_cluster\_size) | The number of nodes in the CVP cluster | `number` | n/a | yes |
| <a name="input_cvp_cluster_vm_admin_user"></a> [cvp\_cluster\_vm\_admin\_user](#input\_cvp\_cluster\_vm\_admin\_user) | User that will be used to connect to CVP cluster instances. | `string` | `"cvpsshadmin"` | no |
| <a name="input_cvp_cluster_vm_key"></a> [cvp\_cluster\_vm\_key](#input\_cvp\_cluster\_vm\_key) | Public SSH key used to access instances in the CVP cluster. | `string` | `null` | no |
| <a name="input_cvp_cluster_vm_password"></a> [cvp\_cluster\_vm\_password](#input\_cvp\_cluster\_vm\_password) | Password used to access instances in the CVP cluster. | `string` | `null` | no |
| <a name="input_cvp_cluster_vm_private_key"></a> [cvp\_cluster\_vm\_private\_key](#input\_cvp\_cluster\_vm\_private\_key) | Private SSH key used to access instances in the CVP cluster. | `string` | `null` | no |
| <a name="input_cvp_cluster_vm_type"></a> [cvp\_cluster\_vm\_type](#input\_cvp\_cluster\_vm\_type) | The type of instances used for CVP | `string` | `"custom-10-20480"` | no |
| <a name="input_cvp_download_token"></a> [cvp\_download\_token](#input\_cvp\_download\_token) | Arista Portal token used to download CVP. | `string` | n/a | yes |
| <a name="input_cvp_enable_advanced_login_options"></a> [cvp\_enable\_advanced\_login\_options](#input\_cvp\_enable\_advanced\_login\_options) | Whether to enable advanced login options on CVP. | `bool` | `false` | no |
| <a name="input_cvp_ingest_key"></a> [cvp\_ingest\_key](#input\_cvp\_ingest\_key) | Key that will be used to authenticate devices to CVP. | `string` | `null` | no |
| <a name="input_cvp_install_size"></a> [cvp\_install\_size](#input\_cvp\_install\_size) | CVP installation size. | `string` | `null` | no |
| <a name="input_cvp_k8s_cluster_network"></a> [cvp\_k8s\_cluster\_network](#input\_cvp\_k8s\_cluster\_network) | Internal network that will be used inside the k8s cluster. Applies only to 2021.1.0+. | `string` | `"10.42.0.0/16"` | no |
| <a name="input_cvp_ntp"></a> [cvp\_ntp](#input\_cvp\_ntp) | NTP server used to keep time synchronization between CVP nodes. | `string` | `"time.google.com"` | no |
| <a name="input_cvp_version"></a> [cvp\_version](#input\_cvp\_version) | CVP version to install on the cluster. | `string` | `"2020.3.1"` | no |
| <a name="input_cvp_vm_image"></a> [cvp\_vm\_image](#input\_cvp\_vm\_image) | Image used to launch VMs. | `string` | `null` | no |
| <a name="input_eos_ip_range"></a> [eos\_ip\_range](#input\_eos\_ip\_range) | IP ranges used by EOS devices that will be managed by the CVP cluster. | `list(any)` | `[]` | no |
| <a name="input_gcp_network"></a> [gcp\_network](#input\_gcp\_network) | The network in which clusters will be launched. Leaving this blank will create a new network. | `string` | `null` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The name of the GCP Project where all resources will be launched. | `string` | `null` | no |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The region in which all GCP resources will be launched. | `string` | n/a | yes |
| <a name="input_gcp_zone"></a> [gcp\_zone](#input\_gcp\_zone) | The zone in which all GCP resources will be launched. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cvp_cluster_nodes_ips"></a> [cvp\_cluster\_nodes\_ips](#output\_cvp\_cluster\_nodes\_ips) | n/a |
| <a name="output_cvp_cluster_ssh_user"></a> [cvp\_cluster\_ssh\_user](#output\_cvp\_cluster\_ssh\_user) | n/a |
| <a name="output_cvp_deviceadd_instructions"></a> [cvp\_deviceadd\_instructions](#output\_cvp\_deviceadd\_instructions) | n/a |
<!-- END_TF_DOCS -->

##  6. <a name='Examples'></a>Examples
<!-- ###  5.1. <a name='UsingtheDockerimage'></a>Using the Docker image
The docker image contains all dependencies pre-installed. It uses the same general syntax as the `.tfvars` method:

```bash
$ docker run --rm -ti -v $HOME/.ssh:/cvp/.ssh -v $(pwd):/cvp test apply -var-file=examples/one-node-cvp-deployment.tfvars -target module.cvp_cluster # first apply only
$ docker run --rm -ti -v $HOME/.ssh:/cvp/.ssh -v $(pwd):/cvp test apply -var-file=examples/one-node-cvp-deployment.tfvars # subsequent applies
```

Some directories can be mounted if you wish to use pre-existing configuration:
- **-v $HOME/.ssh:/cvp/.ssh**: Path to existing SSH keys.
- **-v $HOME/.config/gcloud:/cvp/.gcloud**: Path to an existing gcloud configuration

If those directories are not mounted new configurations will be generated.
-->

###  6.1. <a name='Usinga.tfvarsfile'></a>Using a `.tfvars` file
**Note**: Before running this please replace the `gcp_project_id` variable in the provided example file with the correct name of your project and `cvp_download_token` with your Arista Portal token.

```bash
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars -target module.cvp_cluster # first apply only
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars # subsequent applies
```

###  6.2. <a name='Usingcommand-linevariables:'></a>Using command-line variables:

```bash
$ terraform apply -var gcp_project_id=myproject -var gcp_region=us-central1 -var gcp_zone=a -var cvp_cluster_name=my-cvp-cluster -var cvp_cluster_size=1 -var cvp_cluster_public_management=true -var cvp_cluster_vm_key="~/.ssh/id_rsa.pub" -var cvp_cluster_vm_private_key="~/.ssh/id_rsa" -var cvp_download_token="PLACE_YOUR_PORTAL_TOKEN_HERE" -target module.cvp_cluster # first apply only
$ terraform apply -var gcp_project_id=myproject -var gcp_region=us-central1 -var gcp_zone=a -var cvp_cluster_name=my-cvp-cluster -var cvp_cluster_size=1 -var cvp_cluster_public_management=true -var cvp_cluster_vm_key="~/.ssh/id_rsa.pub" -var cvp_cluster_vm_private_key="~/.ssh/id_rsa" -var cvp_download_token="PLACE_YOUR_PORTAL_TOKEN_HERE" # subsequent applies
```

##  7. <a name='Removingtheenvironment'></a>Removing the environment
In order to remove the environment you launched you can run the following command:

```bash
$ terraform destroy -var-file=examples/one-node-cvp-deployment.tfvars
```

This command removes everything except data disks (and networks when using pre-existing ones) from the GCP project. Please read [other notes](#OtherNotes) below for more info.

##  8. <a name='OtherNotes'></a>Other Notes
- **Data disks**: Data disks will **not** be removed when destroying the environment unless `cvp_cluster_remove_disks` is set to `true`. Make sure to remove them manually when they're no longer needed.

- **target module.cvp_cluster**: Due to limitations in Terraform we need to run it twice when creating the environment for the first time. This is due to the need of referencing instances that are created by the Instance Group Manager when provisioning the cluster, which can only be done after the environment is created. <br />&nbsp;<br />The first run should use the parameter `-target module.cvp_cluster` so that only the cluster creation takes place, ignoring the provisioning part. Once the cluster is running the parameter shouldn't be used anymore, and subsequent runs will both adjust cluster settings and do all necessary provisioning steps.

##  9. <a name='BugsandLimitations'></a>Bugs and Limitations
- Resizing clusters is not supported at this time.
- This module connects to the instance using the `root` user instead of the declared user for provisioning due to limitations in the base image that's being used. If you know your way around terraform and understand what you're doing, this behavior can be changed by editing the `modules/cvp-provision/main.tf` file.
- CVP installation size auto-discovery only works for custom instances at this time.


[ansible-install]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-the-ansible-community-package
[gcloud-install]: https://cloud.google.com/sdk/docs/install
[terraform-download]: https://www.terraform.io/downloads.html
[terraform-tfvars]: https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files
[terraform-no-project]: https://github.com/hashicorp/terraform-provider-google/issues/4856