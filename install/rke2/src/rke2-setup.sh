#!/usr/bin/bash

# Authored By: Markus Walker
# Date Modified: 2/1/23

setupKubectl() {
	echo -e "Installing kubectl..."
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	mkdir -p ~/.kube
	rm kubectl
}

setupServerNodes() {
	echo -e "\nSetting up RKE2 server node..."
	curl -sfL https://get.rke2.io | sudo sh -

    echo -e "\nStarting up RKE2 service..."
    sudo systemctl enable rke2-server
    sudo systemctl start rke2-server
	
	echo -e "\nCopying over kubeconfig file..."
	mkdir -p $HOME/.kube
	sudo cp /etc/rancher/rke2/rke2.yaml $HOME/.kube/config
	sudo chown $(id -u):$(id -g) -R $HOME/.kube/config
	
	echo -e "\nValidating K3s cluster..."
	kubectl get nodes
}

setupAgentNodes() {
	export TOKEN=$(sudo cat /var/lib/rancher/rke2/server/node-token)
	
	echo -e "\nSetting up RKE2 agent node 1..."
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE1}" "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE='agent' sudo sh -"
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE1}" "sudo systemctl enable rke2-agent"
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE1}" "sudo mkdir -p /etc/rancher/rke2/"

	echo -e "\nJoining agent node 1 to cluster..."
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE1}" "echo 'server: https://${SERVER_NODE}:9345' | sudo tee /etc/rancher/rke2/config.yaml"
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE1}" "echo 'token: ${TOKEN}' | sudo tee -a /etc/rancher/rke2/config.yaml"
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE1}" "sudo systemctl start rke2-agent"
	
	echo -e "\nValidating agent node 1 was added..."
	kubectl get nodes
	
	echo -e "\nSetting up RKE2 agent node 2..."
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE2}" "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE='agent' sudo sh -"
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE2}" "sudo systemctl enable rke2-agent"
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE2}" "sudo mkdir -p /etc/rancher/rke2/"

	echo -e "\nJoining agent node 2 to cluster..."
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE2}" "echo 'server: https://${SERVER_NODE}:9345' | sudo tee /etc/rancher/rke2/config.yaml"
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE2}" "echo 'token: ${TOKEN}' | sudo tee -a /etc/rancher/rke2/config.yaml"
	sudo ssh -i "${SSH_KEY}" "${USER}"@"${AGENT_NODE2}" "sudo systemctl start rke2-agent"
	
	echo -e "\nValidating agent node 2 was added..."
	kubectl get nodes
	
	echo -e "\nLabeling agent nodes as worker nodes..."
	kubectl get nodes | grep "<none>" | awk '{print $1}' | xargs -I {} kubectl label node {} node-role.kubernetes.io/worker=worker
	kubectl get nodes	
}

usage() {
	cat << EOF

$(basename "$0")

Setup an RKE2 cluster with 3 nodes. This script assumes you have met the following prerequisites:

	* SSH (requires private key)
	* Sudo access on each machine
	* User is the same on all target machines

USAGE: % ./$(basename "$0") [options]

OPTIONS:
	-h	-> Usage

EXAMPLES:

* Run script

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
	echo -e "\tRKE2 Cluster Setup"
	echo -e "====================================\x1B[0m\n"

	export SSH_KEY=""
	export SERVER_NODE=""
	export AGENT_NODE1=""
	export AGENT_NODE2=""
	export USER=""

	setupKubectl
	setupServerNodes
	setupAgentNodes
}

Main "$@"