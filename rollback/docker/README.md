# Rollback Rancher - Docker

### Description
Bash script to rollback a Rancher server on the designated client machine. Find the usage below:

![Usage](https://github.com/markusewalker/Rancher-Goodies/blob/main/rollback/docker/usage.jpg)

This scirpt assumes that you utilized `upgrade.sh` prior to using this script. This script is meant to be used in the scenario of an immediate upgrade/rollback sceneario. As such, you may have paths that do not match what is in `rollback.sh`.

If that is the case, you will need to ensure you modify `rollback.sh` to match your paths to ensure that the script correctly runs.

### Getting Started
To utilize this script, please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x rollback.sh`.
3. Navigate to the src folder and run the script: `./rollback.sh`.