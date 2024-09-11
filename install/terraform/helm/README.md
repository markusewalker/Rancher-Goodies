# Install Rancher - Terraform

### Description
Installing Rancher using Terraform. Currently, AWS is the only provider you can choose. Please note that if you are planning to use an RPM based install of RKE2, this will not work.

### Getting Started
Assuming that `terraform` is already installed on the client machine, follow the following steps:

1. Fill out `terraform.tfvars` and `variables.tf`. 
2. Run the following command: `terraform apply`.