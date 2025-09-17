# Pull, Tag, Push Images

### Description
Bash script to pull, tag and push specified images that may have been excluded in the rancher-images.txt file.

Prior to running the script, you will need to edit the script to include the following:

- Full path location to the SSH key needed to access the private registry
- Name of the PEM file (include the .pem extension)
- Username of the registry node
- FQDN of the registry node
- Paths for the specified images in the script (include the version number, e.g. rancher/rancher-webhook:v<version number>)
- Docker installed on the private registry

### Getting Started
To utilize this script, please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x registry-images.sh`.
3. Navigate to the src folder and run the script: `sudo ./registry-images.sh`.
