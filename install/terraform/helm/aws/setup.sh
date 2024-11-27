#!/bin/bash

export FQDN=""
export PATH=$PATH:/usr/local/bin
export RKE2_VERSION="v1.30.6+rke2r1"
export RKE2_TOKEN=""
export CERT_VERSION="v1.15.3"
export RANCHER_VERSION="v2.10-head"
export SSH_KEY=""
export PEM=""
export USER="ec2-user"
export REPO="rancher-latest"
export TYPE="latest"
export BOOTSTRAP_PASSWORD=""

if [ "${EUID}" -ne 0 ]; then
  echo -e "Please run as the root user!"
  exit 1
fi

echo -e "Running terraform init..."
terraform init > /dev/null 2>&1

echo -e "\nRunning terraform apply..."
terraform apply --auto-approve

export CLIENT_NODE_FQDN=$(terraform output rke2_client_public_dns | sed 's/"//g')
export SERVER_ONE_PRIVATE_IP=$(terraform output rke2_server1_private_ip | sed 's/"//g')
export SERVER_ONE_FQDN=$(terraform output rke2_server1_public_dns | sed 's/"//g')
export SERVER_TWO_FQDN=$(terraform output rke2_server2_public_dns | sed 's/"//g')
export SERVER_THREE_FQDN=$(terraform output rke2_server3_public_dns | sed 's/"//g')

setupServerOne() {   
  echo -e "\nSSH'ing into the server node 1..."
  echo -e "\nSetting up RKE2 server 1..."
  runSSH "${SERVER_ONE_FQDN}" "sudo useradd -r -c 'etcd user' -s /sbin/nologin -M etcd -U > /dev/null 2>&1"
  runSSH "${SERVER_ONE_FQDN}" "sudo mkdir -p /etc/rancher/rke2"
  runSSH "${SERVER_ONE_FQDN}" "sudo touch /etc/rancher/rke2/config.yaml"
  runSSH "${SERVER_ONE_FQDN}" "printf 'token: ${RKE2_TOKEN}\ntls-san:\n  - ${SERVER_ONE_PRIVATE_IP}\n' | sudo tee /etc/rancher/rke2/config.yaml > /dev/null"    
  runSSH "${SERVER_ONE_FQDN}" "curl -sfL https://get.rke2.io --output install.sh > /dev/null 2>&1"
  runSSH "${SERVER_ONE_FQDN}" "sudo chmod +x install.sh > /dev/null 2>&1"
  runSSH "${SERVER_ONE_FQDN}" "sudo INSTALL_RKE2_VERSION=${RKE2_VERSION} INSTALL_RKE2_TYPE='server' ./install.sh > /dev/null 2>&1"
  runSSH "${SERVER_ONE_FQDN}" "sudo systemctl enable rke2-server > /dev/null 2>&1"
  runSSH "${SERVER_ONE_FQDN}" "sudo systemctl start rke2-server > /dev/null 2>&1"

  echo -e "\nWaiting 1 minute for the RKE2 server to start..."

  runSSH "${SERVER_ONE_FQDN}" "sleep 60"
    
  runSSH "${SERVER_ONE_FQDN}" "sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl > /dev/null 2>&1""
  runSSH "${SERVER_ONE_FQDN}" "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
    
  runSSH "${SERVER_ONE_FQDN}" "sudo mkdir -p /root/.kube"
  runSSH "${SERVER_ONE_FQDN}" "sudo rm kubectl"
  runSSH "${SERVER_ONE_FQDN}" "sudo mv /usr/local/bin/kubectl /usr/bin/kubectl"
    
  runSSH "${SERVER_ONE_FQDN}" "sudo cp /etc/rancher/rke2/rke2.yaml /root/.kube/config"

  scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${SSH_KEY} ${SSH_KEY} ${USER}@${SERVER_ONE_FQDN}:/home/${USER}  
  runSSHOutput "${SERVER_ONE_FQDN}" "sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${PEM} /root/.kube/config ${USER}@${CLIENT_NODE_FQDN}:/home/${USER}"
}

addServers() {
  export TOKEN=$(runSSHOutput "${SERVER_ONE_FQDN}" "sudo cat /var/lib/rancher/rke2/server/node-token")
    
  echo -e "\nSSH'ing into server node 2..."
  echo -e "\nSetting up RKE2 server 2..."
  runSSH "${SERVER_TWO_FQDN}" "sudo mkdir -p /etc/rancher/rke2"
  runSSH "${SERVER_TWO_FQDN}" "sudo touch /etc/rancher/rke2/config.yaml"
  runSSH "${SERVER_TWO_FQDN}" "printf 'server: https://${SERVER_ONE_PRIVATE_IP}:9345\ntoken: ${RKE2_TOKEN}\ntls-san:\n  - ${SERVER_TWO_FQDN}\n' | sudo tee /etc/rancher/rke2/config.yaml > /dev/null"
  runSSH "${SERVER_TWO_FQDN}" "curl -sfL https://get.rke2.io --output install.sh > /dev/null 2>&1"
  runSSH "${SERVER_TWO_FQDN}" "chmod +x install.sh > /dev/null 2>&1"
  runSSH "${SERVER_TWO_FQDN}" "sudo INSTALL_RKE2_VERSION=${RKE2_VERSION} INSTALL_RKE2_TYPE='server' ./install.sh > /dev/null 2>&1"
  runSSH "${SERVER_TWO_FQDN}" "sudo systemctl enable rke2-server > /dev/null 2>&1"
  runSSH "${SERVER_TWO_FQDN}" "sudo systemctl start rke2-server"
    
  echo -e "\nServer node 2 is added to the cluster!"
    
  echo -e "\nSSH'ing into server node 3..."
  echo -e "\nSetting up RKE2 server 3..."
  runSSH "${SERVER_THREE_FQDN}" "sudo mkdir -p /etc/rancher/rke2"
  runSSH "${SERVER_THREE_FQDN}" "sudo touch /etc/rancher/rke2/config.yaml"
  runSSH "${SERVER_THREE_FQDN}" "printf 'server: https://${SERVER_ONE_PRIVATE_IP}:9345\ntoken: ${RKE2_TOKEN}\ntls-san:\n  - ${SERVER_THREE_FQDN}\n' | sudo tee /etc/rancher/rke2/config.yaml > /dev/null"
  runSSH "${SERVER_THREE_FQDN}" "curl -sfL https://get.rke2.io --output install.sh > /dev/null 2>&1"
  runSSH "${SERVER_THREE_FQDN}" "chmod +x install.sh > /dev/null 2>&1"
  runSSH "${SERVER_THREE_FQDN}" "sudo INSTALL_RKE2_VERSION=${RKE2_VERSION} INSTALL_RKE2_TYPE='server' ./install.sh > /dev/null 2>&1"
  runSSH "${SERVER_THREE_FQDN}" "sudo systemctl enable rke2-server > /dev/null 2>&1"
  runSSH "${SERVER_THREE_FQDN}" "sudo systemctl start rke2-server"

  echo -e "\nServer node 3 is added to the cluster!"
}

rancher() {
  echo -e "\nInstalling kubectl and Helm..."
  runSSH "${CLIENT_NODE_FQDN}" "curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl""
  runSSH "${CLIENT_NODE_FQDN}" "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
  runSSH "${CLIENT_NODE_FQDN}" "mkdir -p ~/.kube"
  runSSH "${CLIENT_NODE_FQDN}" "rm kubectl"

  runSSH "${CLIENT_NODE_FQDN}" "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
  runSSH "${CLIENT_NODE_FQDN}" "chmod +x get_helm.sh"
  runSSH "${CLIENT_NODE_FQDN}" "./get_helm.sh"
  runSSH "${CLIENT_NODE_FQDN}" "rm get_helm.sh"

  runSSH "${CLIENT_NODE_FQDN}" "mkdir -p ~/.kube"
  runSSH "${CLIENT_NODE_FQDN}" "mv /home/${USER}/config /home/${USER}/.kube/config"
  runSSH "${CLIENT_NODE_FQDN}" "sed -i 's|server: https://127.0.0.1:6443|server: https://${CP_SERVER_PRIVATE_IP}:6443|' /home/${USER}/.kube/config"

  echo -e "\nAdding Helm chart repo..."
  runSSH "${CLIENT_NODE_FQDN}" "helm repo add ${REPO} https://releases.rancher.com/server-charts/${TYPE}"

  echo -e "\nCreating cattle-system namespace..."
  runSSH "${CLIENT_NODE_FQDN}" "kubectl create ns cattle-system"

  echo -e "\nInstalling cert-manager..."
  runSSH "${CLIENT_NODE_FQDN}" "kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/${CERT_VERSION}/cert-manager.crds.yaml"
  runSSH "${CLIENT_NODE_FQDN}" "helm repo add jetstack https://charts.jetstack.io"
  runSSH "${CLIENT_NODE_FQDN}" "helm repo update"
  runSSH "${CLIENT_NODE_FQDN}" "helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version ${CERT_VERSION}"

  echo -e "\nVerifying cert-manager has been properly setup..."
  runSSHOutput "${CLIENT_NODE_FQDN}" "kubectl get pods --namespace cert-manager"
    
  echo -e "\nDeploying Rancher..."
  runSSHOutput "${CLIENT_NODE_FQDN}" "helm upgrade --install rancher $REPO/rancher --namespace cattle-system \
                                       --set global.cattle.psp.enabled=false \
                                       --set hostname=${FQDN} \
                                       --set rancherImageTag=${RANCHER_VERSION} \
                                       --set bootstrapPassword=${BOOTSTRAP_PASSWORD}"

  echo -e "\nWaiting for Rancher to be rolled out..."
  runSSHOutput "${CLIENT_NODE_FQDN}" "kubectl -n cattle-system rollout status deploy/rancher"

  echo -e "\nVerifying Rancher was successfully deployed..."
  runSSHOutput "${CLIENT_NODE_FQDN}" "kubectl -n cattle-system get deploy rancher"
}

runSSH() {
  local server="$1"
  local cmd="$2"
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${SSH_KEY}" "${USER}@${server}" "${cmd}" > /dev/null 2>&1
}

runSSHOutput() {
  local server="$1"
  local cmd="$2"
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${SSH_KEY}" "${USER}@${server}" "${cmd}"
}

usage() {
	cat << EOF

$(basename "$0")

======================================================
              Setup Rancher w/Helm
======================================================
This script will deploy a Rancher HA setup on top of an RKE2 cluster. You will need the

following:

    * Terraform installed
    * PEM file to ssh into the nodes
    * Run as root

Be sure to run this script on the client node as the root user.

USAGE: % ./$(basename "$0") [options]

OPTIONS:
	-h	-> Usage

EXAMPLES OF USAGE:

* Run script
	
	$ ./$(basename "$0")

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
    setupServerOne
    addServers
    rancher
}

Main "$@"