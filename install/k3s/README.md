# Install K3s Cluster

### Description
Bash script to install and configure a K3s cluster with 3 nodes. Find the usage below:

![Usage](https://github.com/markusewalker/Rancher-Goodies/blob/main/install/k3s/usage.jpg)

As noted in the usage above, you will need to edit the script to fill the requested information in order to properly run the script.

Additionally, this script will install the tools `kubectl` on the client machine.

### Getting Started
To utilize this script, please follow the below workflow:

1. Clone the script into your environment.
2. Make sure the script is executable using the command `chmod +x k3s-setup.sh`.
3. Navigate to the src folder and run the script: `./k3s-setup.sh`.

### BATS Testing
Along with this script, you can perform unit testing using BATS (Bash Automated Testing System). In order to do this, you will need to ensure BATS is either installed on your system, or you directly invoke the test.bats file.

If you choose to install BATS directly on your system, following this documentation: https://bats-core.readthedocs.io/en/stable/installation.html. Once done, you can simply call `bats test.bats` to run the tests. This is further explained below.

In the `k3s` folder, run the following commands:

```
git init
git submodule add https://github.com/bats-core/bats-core.git test/bats
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
```

Once done, navigate to the `k3s/src` folder and perform one of the following commands:

```
bats test.bats
../test/bats/bin/bats test.bats
```

![BATS Testing Result](https://github.com/markusewalker/Rancher-Goodies/blob/main/install/k3s/bats.jpg)