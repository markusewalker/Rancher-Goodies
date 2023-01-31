# Upgrade Rancher w/Volume Mounts - Docker

### Description
Bash script to upgrade a Rancher server with volume mounts on the designated client machine. Find the usage below:

![Usage](https://github.com/markusewalker/Rancher-Goodies/blob/main/upgrade/docker/volume-mount/upgrade.jpg)

You are able to use this script in conjuction with `rollback.sh` for a scenario of upgrading/rolling back. If you do this, you will need to sure that you DO NOT modify any of the paths in the `mount-upgrade.sh` and `rollback.sh` code.

If you do use `rollback.sh` and have modified paths, then you will need to ensure you modify `rollback.sh` to match your paths to ensure that the script correctly runs.

In contradiction, you DO NOT to run `install.sh` or `mount-install.sh` prior to running this script; it does not depend on that script.

### Getting Started
To utilize this script, please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x mount-upgrade.sh`.
3. Navigate to the src folder and run the script: `./mount-upgrade.sh`.

### BATS Testing
Along with this script, you can perform unit testing using BATS (Bash Automated Testing System). In order to do this, you will need to ensure BATS is either installed on your system, or you directly invoke the test.bats file.

If you choose to install BATS directly on your system, following this documentation: https://bats-core.readthedocs.io/en/stable/installation.html. Once done, you can simply call `bats test.bats` to run the tests. This is further explained below.

In the `volume-mount` folder, run the following commands:

```
git init
git submodule add https://github.com/bats-core/bats-core.git test/bats
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
```

Once done, navigate to the `volume-mount/src` folder and perform one of the following commands:

```
bats test.bats
../test/bats/bin/bats test.bats
```

![BATS Testing Result](https://github.com/markusewalker/Rancher-Goodies/blob/main/upgrade/docker/volume-mount/bats.jpg)
