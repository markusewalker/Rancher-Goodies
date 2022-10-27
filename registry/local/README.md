# Create Private Registry

### Description
Bash script to create a private registry using self-signed certificates and Docker. Once done, Rancher images will be pulled and pushed to the created private registry.

![Usage](https://github.com/markusewalker/Rancher-Goodies/blob/main/registry/local/registry.jpg)

As mentioned in the above usage, this script requires that the tools `docker` and `htpasswd` are already installed on the client machine.

Prior to running the script, you will need to edit the script to include the following:

- Registry username
- Registry password
- Registry name
- DNS for the client machine (this serves as the private registry machine)
- Rancher version (needed to specify what images to pull and push)

### Getting Started
To utilize this script, please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x create-registry.sh`.
3. Navigate to the src folder and run the script: `./create-registry.sh`.
