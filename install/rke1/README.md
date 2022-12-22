# Install RKE1 Cluster

### Description
Bash script to install and configure a RKE1 cluster with 3 nodes. Find the usage below:

![Usage](https://github.com/markusewalker/Rancher-Goodies/blob/main/install/rke1//usage.jpg)

As noted in the usage above, you will need to edit the script to fill the requested information in order to properly run the script.

Additionally, this script will install the tools `kubectl` and the RKE CLI on the client machine if they do not already exist.

### Getting Started
To utilize this script, please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x rke-setup.sh`.
3. Navigate to the src folder and run the script: `./rke-setup.sh`.
