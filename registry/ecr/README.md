# Populate ECR Private Registry

### Description
Bash script to populate an ECR private registry with Rancher images using self-signed certificates and Docker.

![Usage](https://github.com/markusewalker/Rancher-Goodies/blob/main/registry/ecr/ecr-registry.jpg)

As mentioned in the above usage, this script requires that the tools `docker` and the AWS CLI are already installed and configured on the client machine.

Prior to running the script, you will need to edit the script to include the following:

- ECR name
- ECR username
- Rancher version (needed to specify what images to pull and push)

### Getting Started
To utilize this script, please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x ecr-registry.sh`.
3. Navigate to the src folder and run the script: `./ecr-registry.sh`.
