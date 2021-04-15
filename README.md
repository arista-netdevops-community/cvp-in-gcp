# cvp-in-gcp

Templates to launch fully-functional CVP clusters in GCP

## Requisites
### terraform >= 0.13
This module should work with any terraform version above 0.13. You can [download it from the official website][terraform-download].

Terraform is distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`.

### gcloud client
You must have the Google Cloud SDK installed and authenticated. For installation details please see [here][gcloud-install].

We suggest that you create a profile and authenticate the cli using these steps:

```bash
$ gcloud config configurations create cvp-profile
$ gcloud config configurations activate cvp-profile
$ gcloud init
$ gcloud auth application-default login
```

Feel free to change `cvp-profile` to whatever profile name you prefer.

## Running terraform
These steps assume that you created a profile following the steps in the `Requisites/gcloud client` section:
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

### Variables
Mandatory variables will be asked at runtime unless specified on the command line or using a [.tfvars file](terraform-tfvars)

#### Mandatory
- **gcp_project_id**: The name of the GCP Project where all resources will be launched. May also be obtained from the `GOOGLE_PROJECT` environment variable.
- **gcp_region**: The region in which all GCP resources will be launched.
- **gcp_zone**: The zone in which all GCP resources will be launched. Must be a valid zone within the desired `gcp_region`.
- **cvp_cluster_name**: The name of the CVP cluster
- **cvp_cluster_size**: The number of nodes in the CVP cluster. Must be 1 or 3 nodes.

#### Optional
- **gcp_network**: The network in which clusters will be launched. Leaving this blank will create a new network.
- **cvp_cluster_vmtype**: The type of instances used for CVP
- **cvp_cluster_public_management**: Whether the cluster UI and SSH ports (https/ssh) is publically accessible over the internet. Defaults to `false`.

# Examples
## Using command-line variables:

```bash
$ terraform apply -var gcp_project_id=myproject -var cvp_cluster_name=mycluster -var cvp_cluster_size=1 -var gcp_region=us-central1 -var gcp_zone=a
```

## Using a `.tfvars` file:
**Note**: Before running this please replace the `gcp_project_id` variable in the provided example file with the correct name of your project.

```
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars
```

# Bugs
- [Running the module without explicitely setting a project will fail][terraform-no-project]

[gcloud-install]: https://cloud.google.com/sdk/docs/install
[terraform-download]: https://www.terraform.io/downloads.html
[terraform-tfvars]: https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files
[terraform-no-project]: https://github.com/hashicorp/terraform-provider-google/issues/4856