# Install Air-gapped Rancher - Hauler

### Description
Bash script to install an air-gapped Rancher server using the Hauler tool.

### Getting Started
To utilize this script, you will need to have the following:

    - 1 client RHEL 8.x node
    - 1 registry RHEL 8.x node
    - 1 RKE2 server RHEL 8.x node
    - 2 RKE2 agent RHEL 8.x nodes
    - PEM file to SSH into the nodes

Please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x airgap.sh`.
3. Navigate to the src folder and run the script to view the usage: `./airgap.sh`.
4. Fill out the environmental variables based upon your specifics.

Currently, you will need to run the script with the appropriate flag on each of the nodes. An enhancement to run this from only one node is being further looked at in the near future.