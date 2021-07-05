# cvp-in-gcp

Templates to launch fully functional CVP clusters in GCP.

<!-- vscode-markdown-toc -->
* 1. [TLDR](#TLDR)
* 2. [Requisites](#Requisites)
	* 2.1. [terraform](#terraform)
	* 2.2. [Google Cloud SDK](#GoogleCloudSDK)
	* 2.3. [ansible](#ansible)
* 3. [Quickstart](#Quickstart)
* 4. [Adding EOS devices](#AddingEOSdevices)
* 5. [Variables](#Variables)
	* 5.1. [Inputs](#Inputs)
	* 5.2. [Outputs](#Outputs)
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
###  2.1. <a name='terraform'></a>terraform
This module is tested with terraform `TERRAFORM_VERSION`, but should work with any terraform version above the version shown below. You can [download it from the official website][terraform-download].

Terraform is distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`.

<!-- BEGIN_TF_REQS -->
<!-- END_TF_REQS -->

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
Required variables are asked at runtime unless specified on the command line. Using a [.tfvars file](terraform-tfvars) is recommended in most cases.
<!-- BEGIN_TF_DOCS -->
###  5.1. <a name='Inputs'></a>Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cvp_cluster_centos_version"></a> [cvp\_cluster\_centos\_version](#input\_cvp\_cluster\_centos\_version) | The Centos version used by CVP instances. If not provided we'll try to choose the appropriate one based on the CVP version that's being installed. | `string` | `null` | no |
| <a name="input_cvp_cluster_name"></a> [cvp\_cluster\_name](#input\_cvp\_cluster\_name) | The name of the CVP cluster. | `string` | n/a | yes |
| <a name="input_cvp_cluster_public_eos_communication"></a> [cvp\_cluster\_public\_eos\_communication](#input\_cvp\_cluster\_public\_eos\_communication) | Whether the ports used by EOS devices to communicate to CVP are publically accessible over the internet. | `bool` | `false` | no |
| <a name="input_cvp_cluster_public_management"></a> [cvp\_cluster\_public\_management](#input\_cvp\_cluster\_public\_management) | Whether the cluster management interfaces (https/ssh) are publically accessible over the internet. | `bool` | `false` | no |
| <a name="input_cvp_cluster_size"></a> [cvp\_cluster\_size](#input\_cvp\_cluster\_size) | The number of nodes in the CVP cluster. Must be 1 or 3 nodes. | `number` | `1` | no |
| <a name="input_cvp_cluster_vm_admin_user"></a> [cvp\_cluster\_vm\_admin\_user](#input\_cvp\_cluster\_vm\_admin\_user) | User that will be used to connect to CVP cluster instances. Should be used in conjunction with cvp\_cluster\_vm\_key. | `string` | `"cvpsshadmin"` | no |
| <a name="input_cvp_cluster_vm_key"></a> [cvp\_cluster\_vm\_key](#input\_cvp\_cluster\_vm\_key) | Public SSH key used to access instances in the CVP cluster. | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_cvp_cluster_vm_password"></a> [cvp\_cluster\_vm\_password](#input\_cvp\_cluster\_vm\_password) | Password used to access instances in the CVP cluster. | `string` | `null` | no |
| <a name="input_cvp_cluster_vm_private_key"></a> [cvp\_cluster\_vm\_private\_key](#input\_cvp\_cluster\_vm\_private\_key) | Private SSH key used to access instances in the CVP cluster. This should match the public key provided on the cvp\_cluster\_vm\_key variable. | `string` | `"~/.ssh/id_rsa"` | no |
| <a name="input_cvp_cluster_vm_type"></a> [cvp\_cluster\_vm\_type](#input\_cvp\_cluster\_vm\_type) | The type of instances used for CVP. | `string` | `"custom-10-20480"` | no |
| <a name="input_cvp_download_token"></a> [cvp\_download\_token](#input\_cvp\_download\_token) | Arista Portal token used to download CVP. May be obtained on https://www.arista.com/en/users/profile under Portal Access. | `string` | n/a | yes |
| <a name="input_cvp_enable_advanced_login_options"></a> [cvp\_enable\_advanced\_login\_options](#input\_cvp\_enable\_advanced\_login\_options) | Whether to enable advanced login options on CVP. | `bool` | `false` | no |
| <a name="input_cvp_ingest_key"></a> [cvp\_ingest\_key](#input\_cvp\_ingest\_key) | Key that will be used to authenticate devices to CVP. | `string` | `null` | no |
| <a name="input_cvp_install_size"></a> [cvp\_install\_size](#input\_cvp\_install\_size) | CVP installation size. | `string` | `null` | no |
| <a name="input_cvp_k8s_cluster_network"></a> [cvp\_k8s\_cluster\_network](#input\_cvp\_k8s\_cluster\_network) | Internal network that will be used inside the k8s cluster. Applies only to 2021.1.0+. | `string` | `"10.42.0.0/16"` | no |
| <a name="input_cvp_ntp"></a> [cvp\_ntp](#input\_cvp\_ntp) | NTP server used to keep time synchronization between CVP nodes. | `string` | `"time.google.com"` | no |
| <a name="input_cvp_version"></a> [cvp\_version](#input\_cvp\_version) | CVP version to install on the cluster. | `string` | `"2021.1.1"` | no |
| <a name="input_cvp_vm_image"></a> [cvp\_vm\_image](#input\_cvp\_vm\_image) | Image used to launch VMs. The module will try to guess the best image based on the CVP version if not provided. | `string` | `null` | no |
| <a name="input_eos_ip_range"></a> [eos\_ip\_range](#input\_eos\_ip\_range) | IP ranges used by EOS devices that will be managed by the CVP cluster. Should be set when cvp\_cluster\_public\_eos\_communication is set to false, otherwise, devices won't be able to communicate and stream to CVP. | `list(any)` | `[]` | no |
| <a name="input_gcp_credentials"></a> [gcp\_credentials](#input\_gcp\_credentials) | JSON file containing GCP credentials. Leave blank to use gcloud authentication. | `string` | `null` | no |
| <a name="input_gcp_network"></a> [gcp\_network](#input\_gcp\_network) | The network in which clusters will be launched. Leaving this blank will create a new network. | `string` | `null` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The name of the GCP Project where all resources will be launched. | `string` | n/a | yes |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The region in which all GCP resources will be launched. Must be a valid zone within the desired gcp\_region. | `string` | n/a | yes |
| <a name="input_gcp_zone"></a> [gcp\_zone](#input\_gcp\_zone) | The zone in which all GCP resources will be launched. | `string` | n/a | yes |

###  5.2. <a name='Outputs'></a>Outputs

| Name | Description |
|------|-------------|
| <a name="output_cvp_instances_credentials"></a> [cvp\_instances\_credentials](#output\_cvp\_instances\_credentials) | Public IP addresses and usernames of the cluster instances. |
| <a name="output_cvp_terminattr_instructions"></a> [cvp\_terminattr\_instructions](#output\_cvp\_terminattr\_instructions) | Instructions to add EOS devices to the CVP cluster. |
<!-- END_TF_DOCS -->

##  6. <a name='Examples'></a>Examples
###  6.1. <a name='Usinga.tfvarsfile'></a>Using a `.tfvars` file
**Note**: Before running this please replace the `gcp_project_id` variable in the provided example file with the correct name of your project and `cvp_download_token` with your Arista Portal token.

```bash
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars
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