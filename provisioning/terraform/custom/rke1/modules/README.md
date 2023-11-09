# Provision RKE1 Custom Cluster - Terraform

### Description
Provisioning a RKE1 custom driver cluster using Terraform. Currently, AWS is the provider used in order to do this.

### Getting Started
Assuming that `terraform` is already installed on the client machine, follow the following steps:

1. Fill out `terraform.tfvars` and `variables.tf` in this directory and the `modules` directory. 
2. Run the `cluster.sh` script.