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

# Bugs
- [Running the module without explicitely setting a project will fail][terraform-no-project]

[gcloud-install]: https://cloud.google.com/sdk/docs/install
[terraform-download]: https://www.terraform.io/downloads.html
[terraform-no-project]: https://github.com/hashicorp/terraform-provider-google/issues/4856