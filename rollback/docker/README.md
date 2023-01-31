# Rollback Rancher - Docker

### Description
Bash script to rollback a Rancher server on the designated client machine. Find the usage below:

![Usage](https://github.com/markusewalker/Rancher-Goodies/blob/main/rollback/docker/rollback.jpg)

This scirpt assumes that you utilized `upgrade.sh` prior to using this script. This script is meant to be used in the scenario of an immediate upgrade/rollback sceneario. As such, you may have paths that do not match what is in `rollback.sh`.

If that is the case, you will need to ensure you modify `rollback.sh` to match your paths to ensure that the script correctly runs.

### Getting Started
To utilize this script, please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x rollback.sh`.
3. Navigate to the src folder and run the script: `./rollback.sh`.

### BATS Testing
Along with this script, you can perform unit testing using BATS (Bash Automated Testing System). In order to do this, you will need to ensure BATS is either installed on your system, or you directly invoke the test.bats file.

If you choose to install BATS directly on your system, following this documentation: https://bats-core.readthedocs.io/en/stable/installation.html. Once done, you can simply call `bats test.bats` to run the tests. This is further explained below.

In the `rollback` folder, run the following commands:

```
git init
git submodule add https://github.com/bats-core/bats-core.git test/bats
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
```

Once done, navigate to the `rollback/src` folder and perform one of the following commands:

```
bats test.bats
../test/bats/bin/bats test.bats
```

![BATS Testing Result](https://github.com/markusewalker/Rancher-Goodies/blob/main/rollback/bats/rollback.jpg)

