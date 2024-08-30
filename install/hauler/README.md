# Install Air-gapped Rancher - Hauler

### Description
Bash script to install an air-gapped Rancher server using the Hauler tool.

### Getting Started
To utilize this script, you will need to have the following:

    - 1 client RHEL 8.x node
    - PEM file to SSH into the nodes

Included are Terraform files for you to be able to easily setup the above, excluding the PEM file. All that is needed is filling out `terraform.tfvars` to your specific needs. Afterwards, simply run `terraform apply`.

NOTE: This script currently works only with RHEL 8.x machines.

Once done, you will need to run the `airgap.sh` script. Please follow the below workflow:

1. Clone the script into your environment.
3. Navigate to the src folder.
3. Fill out the appropriate variables found in the `airgap.sh` script.
4. Run `./airgap.sh`. This will kick off the Terraform infrastructure to create the following:
     - Registry node, RKE2 server, 2 agent nodes, AWS 53 record, load balancer and target groups
5. Upon completion of the script, you will have a functioning Rancher environment. You will need to drop the public IP address in AWS.