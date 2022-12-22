#!/usr/bin/bash

# Authored By: Markus Walker
# Date Modified: 12/21/22

setupRKE() {
    echo -e "Downloading RKE CLI..."
    wget https://github.com/rancher/rke/releases/download/${VERSION}/rke_${OS}-${ARCH}

    echo -e "\nRenaming RKE CLI..."
    mv rke_${OS}-${ARCH} rke
	chmod +x rke

    echo -e "\nMoving RKE CLI to /usr/local/bin..."
    sudo mv rke /usr/local/bin

    echo -e "\nVerifying Rancher RKE is setup..."
    rke
}

setupKubelet() {
    echo -e "\nInstalling kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
}

runRKE() {
    echo -e "\nCreating cluster.yml file..."
    cat << EOF >> cluster.yml
ssh_key_path: ${SSH_PATH}
kubernetes_version: ${KUBERNETES_VERSION}
nodes:
  - address: ${NODE1}
    user: ${USER}
    role: [etcd, controlplane,worker]
  - address: ${NODE2}
    user: ${USER}
    role: [etcd, controlplane,worker]
  - address: ${NODE3}
    user: ${USER}
    role: [etcd, controlplane,worker]
EOF

    rke up --config cluster.yml

    echo -e "\nCopying over kubeconfig file to home directory..."
    cp kube_config_cluster.yml $HOME/.kube/config

    echo -e "\nVerifying that the cluster is up and running..."
    kubectl get nodes
}

usage() {
	cat << EOF

$(basename "$0")

Setup an RKE1 cluster with 3 nodes. This script assumes you have the following installed on each of the targeted machines:

    - Docker
    - SSH

The script will install RKE CLI and kubectl on the machine you run the script from.

You will need to provide the following information before running the script:

    - SSH Key Path
    - Kubernetes Version
    - Node1 Public IP Address
    - Node2 Public IP Address
    - Node3 Public IP Address
    - User for each node (should be the same)

USAGE: % ./$(basename "$0") [options]

OPTIONS:
	-h	-> Usage

EXAMPLES:

* Run script interactively

	% ./$(basename "$0")

EOF

}

while getopts "h" opt; do
	case ${opt} in
		h)
                	usage
                	exit 0;;
		*)
                	echo "Invalid option. Valid option(s) are [-h]." 2>&1
                	exit 1;;
	esac
done

Main() {
	echo -e "\x1B[96m===================================="
	echo -e "\tRKE1 Cluster Setup"
	echo -e "====================================\x1B[0m\n"

    	export OS=`uname -s | awk '{print tolower($0)}'`
    	export VERSION=""
    	export ARCH="amd64"
    	export SSH_PATH=""
    	export KUBERNETES_VERSION=""
    	export NODE1=""
    	export NODE2=""
    	export NODE3=""
    	export USER=""

    	setupRKE
    	setupKubelet
    	runRKE
}

Main "$@"
