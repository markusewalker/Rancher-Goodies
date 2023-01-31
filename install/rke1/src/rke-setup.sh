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

setupKubectl() {
    echo -e "\nInstalling kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
}

runRKE() {
    echo -e "\nCreating cluster.yml file..."
    cat << EOF >> cluster.yml
kubernetes_version: ${KUBERNETES_VERSION}
nodes:
  - address: ${NODE1_PUBLIC}
    port: ${PORT}
    internal_address: ${NODE1_PRIVATE}
    ssh_key_path: ${SSH_PATH_NODE1}
    user: ${USER}
    role: [etcd, controlplane,worker]
  - address: ${NODE2_PUBLIC}
    port: ${PORT}
    internal_address: ${NODE2_PRIVATE}
    ssh_key_path: ${SSH_PATH_NODE2}
    user: ${USER}
    role: [etcd, controlplane,worker]
  - address: ${NODE3_PUBLIC}
    port: ${PORT}
    internal_address: ${NODE3_PRIVATE}
    ssh_key_path: ${SSH_PATH_NODE3}
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

You will need to provide the following information before running the script:

    - SSH Key Path for each node
    - Kubernetes Version
    - Node1 Public/Private IP Address
    - Node2 Public/Private IP Address
    - Node3 Public/Private IP Address
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
    	export USER="ubuntu"
    	export PORT=22
    	export SSH_PATH_NODE1=""
    	export SSH_PATH_NODE2=""
    	export SSH_PATH_NODE3=""
    	export KUBERNETES_VERSION=""
    	export NODE1_PUBLIC=""
    	export NODE1_PRIVATE=""
    	export NODE2_PUBLIC=""
    	export NODE2_PRIVATE=""
    	export NODE3_PUBLIC=""
    	export NODE3_PRIVATE=""
   
    	setupRKE
    	setupKubectl
    	runRKE
}

Main "$@"
