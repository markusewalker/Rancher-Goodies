#!/bin/bash

export FQDN=""
export INTERNAL_FQDN=""
export PATH=$PATH:/usr/local/bin
export RKE2_VERSION="v1.30.3"
export CERT_VERSION="v1.15.3"
export RANCHER_VERSION="v2.9.0"
export BOOTSTRAP_PASSWORD=""
export SSH_KEY=""
export USER="ec2-user"
export RHEL_VERSION=el8

if [ "${EUID}" -ne 0 ]; then
  echo -e "\nPlease run as the root user!"
  exit 1
fi

if type rpm > /dev/null 2>&1 ; then export EL=${RHEL_VERSION:-$(rpm -q --queryformat '%{RELEASE}' rpm | grep -o "el[[:digit:]]" )} ; fi

echo -e "Running terraform init..."
terraform init > /dev/null 2>&1

echo -e "\nRunning terraform apply..."
terraform apply --auto-approve

export REGISTRY_FQDN=$(terraform output registry_public_dns | sed 's/"//g')
export REGISTRY_IP=$(terraform output registry_private_ip | sed 's/"//g')
export CP_SERVER_PRIVATE_IP=$(terraform output rke2_server_private_ip | sed 's/"//g')
export CP_SERVER_FQDN=$(terraform output rke2_server_public_dns | sed 's/"//g')
export AGENT_NODE1_FQDN=$(terraform output rke2_agent1_public_dns | sed 's/"//g')
export AGENT_NODE2_FQDN=$(terraform output rke2_agent2_public_dns | sed 's/"//g')

preReqs() {
  echo -e "\nInstalling required packages..."

  yum install sudo -y > /dev/null 2>&1
  yum install jq -y > /dev/null 2>&1
  
  curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash  > /dev/null 2>&1
  curl -sfL https://get.hauler.dev | bash > /dev/null 2>&1
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null 2>&1
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl > /dev/null 2>&1
  mkdir -p /root/.kube
  rm kubectl

  sudo mv /usr/local/bin/helm /usr/bin/helm > /dev/null 2>&1
  sudo mv /usr/local/bin/hauler /usr/bin/hauler > /dev/null 2>&1
  sudo mv /usr/local/bin/kubectl /usr/bin/kubectl > /dev/null 2>&1

  helm repo add jetstack https://charts.jetstack.io > /dev/null 2>&1
  helm repo update > /dev/null 2>&1
}

setupOS() {
  sudo yum remove -y firewalld > /dev/null 2>&1
    
  echo -e "\nDisabling nm-cloud-setup..."
  sudo systemctl disable nm-cloud-setup.service > /dev/null 2>&1
  sudo systemctl disable nm-cloud-setup.timer > /dev/null 2>&1
  sudo systemctl reload NetworkManager > /dev/null 2>&1
    
  echo -e "\nInstalling base packages..."
  sudo yum install -y iptables container-selinux iptables libnetfilter_conntrack libnfnetlink libnftnl policycoreutils-python-utils cryptsetup iscsi-initiator-utils > /dev/null 2>&1
  sudo systemctl enable --now iscsid > /dev/null 2>&1
  sudo echo -e "[keyfile]\nunmanaged-devices=interface-name:cali*;interface-name:flannel*" > /etc/NetworkManager/conf.d/rke2-canal.conf > /dev/null 2>&1
    
  sudo yum clean all  > /dev/null 2>&1
}

setupControlPlane() {
  echo -e "\nSetting kernel settings in the control plane node..."
  kernelSettingsFunction=$(declare -f kernelSettings)
  runSSH "${CP_SERVER_FQDN}" "${kernelSettingsFunction}; kernelSettings"

  echo -e "\nSetting up the OS in the control plane node..."
  setupOSFunction=$(declare -f setupOS)
  runSSH "${CP_SERVER_FQDN}" "${setupOSFunction}; setupOS"
    
  echo -e "\nSSH'ing into the control plane node..."
  echo -e "\nSetting up RKE2 server..."
  runSSH "${CP_SERVER_FQDN}" "sudo useradd -r -c 'etcd user' -s /sbin/nologin -M etcd -U > /dev/null 2>&1"
    
  runSSH "${CP_SERVER_FQDN}" "sudo mkdir -p /etc/rancher/rke2/ /var/lib/rancher/rke2/server/manifests/ /var/lib/rancher/rke2/agent/images"
  runSSH "${CP_SERVER_FQDN}" "curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${RKE2_VERSION} sudo sh - > /dev/null 2>&1"
  runSSH "${CP_SERVER_FQDN}" "sudo systemctl enable rke2-server > /dev/null 2>&1"
  runSSH "${CP_SERVER_FQDN}" "sudo systemctl start rke2-server > /dev/null 2>&1"

  echo -e "\nWaiting 2 minutes for the RKE2 server to start..."

  runSSH "${CP_SERVER_FQDN}" "sleep 120"
    
  runSSH "${CP_SERVER_FQDN}" "sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl > /dev/null 2>&1""
  runSSH "${CP_SERVER_FQDN}" "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
    
  runSSH "${CP_SERVER_FQDN}" "sudo mkdir -p /root/.kube"
  runSSH "${CP_SERVER_FQDN}" "sudo rm kubectl"
  runSSH "${CP_SERVER_FQDN}" "sudo mv /usr/local/bin/kubectl /usr/bin/kubectl"
    
  runSSH "${CP_SERVER_FQDN}" "sudo cp /etc/rancher/rke2/rke2.yaml /root/.kube/config"

  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${SSH_KEY} ${USER}@${CP_SERVER_PRIVATE_IP} "sudo cat /root/.kube/config" > ~/.kube/config
  sed -i "s|server: https://127.0.0.1:6443|server: https://${CP_SERVER_PRIVATE_IP}:6443|" ~/.kube/config
  kubectl get nodes
}

setupAgent() {
  echo -e "\nSetting kernel settings in the agent nodes..."
  kernelSettingsFunction=$(declare -f kernelSettings)
  runSSH "${AGENT_NODE1_FQDN}" "${kernelSettingsFunction}; kernelSettings"
  runSSH "${AGENT_NODE2_FQDN}" "${kernelSettingsFunction}; kernelSettings"

  echo -e "\nSetting up the OS in the agent nodes..."
  setupOSFunction=$(declare -f setupOS)
  runSSH "${AGENT_NODE1_FQDN}" "${setupOSFunction}; setupOS"
  runSSH "${AGENT_NODE2_FQDN}" "${setupOSFunction}; setupOS"

  echo -e "\nAdding RKE2 RPM in the agent nodes..."
  setupRKE2RPMFunction=$(declare -f setupRKE2RPM)
  runSSH "${AGENT_NODE1_FQDN}" "${setupRKE2RPMFunction}; setupRKE2RPM"
  runSSH "${AGENT_NODE2_FQDN}" "${setupRKE2RPMFunction}; setupRKE2RPM"

  export TOKEN=$(runSSHOutput "${CP_SERVER_FQDN}" "sudo cat /var/lib/rancher/rke2/server/node-token")
    
  echo -e "\nSSH'ing into agent node 1..."
  echo -e "\nSetting up RKE2 agent 1..."
  runSSH "${AGENT_NODE1_FQDN}" "sudo yum install rke2-agent -y > /dev/null 2>&1"
  runSSH "${AGENT_NODE1_FQDN}" "sudo systemctl enable rke2-agent > /dev/null 2>&1"
  runSSH "${AGENT_NODE1_FQDN}" "sudo mkdir -p /etc/rancher/rke2/"

  runSSH "${AGENT_NODE1_FQDN}" "echo 'server: https://${CP_SERVER_PRIVATE_IP}:9345' | sudo tee /etc/rancher/rke2/config.yaml"
  runSSH "${AGENT_NODE1_FQDN}" "echo 'token: ${TOKEN}' | sudo tee -a /etc/rancher/rke2/config.yaml"
  runSSH "${AGENT_NODE1_FQDN}" "sudo systemctl start rke2-agent"

  kubectl get nodes
    
  echo -e "\nAgent node 1 is added to the cluster!"
    
  echo -e "\nSSH'ing into agent node 2..."
  echo -e "\nSetting up RKE2 agent 2..."
  runSSH "${AGENT_NODE2_FQDN}" "sudo yum install rke2-agent -y > /dev/null 2>&1"
  runSSH "${AGENT_NODE2_FQDN}" "sudo systemctl enable rke2-agent > /dev/null 2>&1"
  runSSH "${AGENT_NODE2_FQDN}" "sudo mkdir -p /etc/rancher/rke2/"

  runSSH "${AGENT_NODE2_FQDN}" "echo 'server: https://${CP_SERVER_PRIVATE_IP}:9345' | sudo tee /etc/rancher/rke2/config.yaml"
  runSSH "${AGENT_NODE2_FQDN}" "echo 'token: ${TOKEN}' | sudo tee -a /etc/rancher/rke2/config.yaml"
  runSSH "${AGENT_NODE2_FQDN}" "sudo systemctl start rke2-agent"

  kubectl get nodes

  echo -e "\nAgent node 2 is added to the cluster!"
}

setupRegistry() {
  echo -e "\nSSH'ing into the registry server..."
  echo -e "\nInstalling required packages..."
    
  runSSH "${REGISTRY_FQDN}" "sudo yum install jq -y > /dev/null 2>&1"
  runSSH "${REGISTRY_FQDN}" "curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash  > /dev/null 2>&1"
  runSSH "${REGISTRY_FQDN}" "sudo curl -sfL https://get.hauler.dev | sudo bash > /dev/null 2>&1"
  runSSH "${REGISTRY_FQDN}" "sudo mv /usr/local/bin/helm /usr/bin/helm > /dev/null 2>&1"
    
  runSSH "${REGISTRY_FQDN}" "sudo mkdir -p /opt/hauler"
  runSSH "${REGISTRY_FQDN}" "sudo touch /opt/hauler/airgap_hauler.yaml"
  runSSH "${REGISTRY_FQDN}" "sudo chown -R ${USER}:${USER} /opt/hauler"
    
  echo -e "\nCreating hauler manifest..."  
  runSSH "${REGISTRY_FQDN}" "helm repo add jetstack https://charts.jetstack.io > /dev/null 2>&1"
  runSSH "${REGISTRY_FQDN}" "helm repo update > /dev/null 2>&1"
    
  runSSH "${REGISTRY_FQDN}" "tee -a /opt/hauler/airgap_hauler.yaml > /dev/null << EOF
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Images
metadata:
  name: rancher-images
  annotations:
    hauler.dev/platform: linux/amd64
spec:
  images:
EOF"

  runSSH "${REGISTRY_FQDN}" "for i in $(helm template jetstack/cert-manager --version $CERT_VERSION | awk '$1 ~ /image:/ {print $2}' | sed 's/\"//g'); do 
    echo "    - name: "$i >> /opt/hauler/airgap_hauler.yaml
  done"

  runSSH "${REGISTRY_FQDN}" "curl -sL https://github.com/rancher/rancher/releases/download/${RANCHER_VERSION}/rancher-images.txt | while read -r i; do
    echo \"    - name: \"\$i >> /opt/hauler/airgap_hauler.yaml
  done"
  
  runSSH "${REGISTRY_FQDN}" "sed -i '/windows/d' /opt/hauler/airgap_hauler.yaml"

  runSSH "${REGISTRY_FQDN}" "tee -a /opt/hauler/airgap_hauler.yaml > /dev/null << EOF
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Charts
metadata:
  name: rancher-charts
spec:
  charts:
    - name: rancher
      repoURL: https://releases.rancher.com/server-charts/latest
      version: $RANCHER_VERSION
    - name: cert-manager
      repoURL: https://charts.jetstack.io
      version: $CERT_VERSION
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Files
metadata:
  name: rancher-files
spec:
  files:
    - path: https://github.com/rancher/rke2-packaging/releases/download/$RKE2_VERSION%2Brke2r1.stable.0/rke2-common-$RKE2_VERSION.rke2r1-0.$EL.x86_64.rpm
    - path: https://github.com/rancher/rke2-packaging/releases/download/$RKE2_VERSION%2Brke2r1.stable.0/rke2-agent-$RKE2_VERSION.rke2r1-0.$EL.x86_64.rpm
    - path: https://github.com/rancher/rke2-packaging/releases/download/$RKE2_VERSION%2Brke2r1.stable.0/rke2-server-$RKE2_VERSION.rke2r1-0.$EL.x86_64.rpm
    - path: https://github.com/rancher/rke2-selinux/releases/download/v0.17.stable.1/rke2-selinux-0.17-1.$EL.noarch.rpm
    - path: https://get.helm.sh/helm-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name)-linux-amd64.tar.gz
EOF"

  echo -e "\nCreated airgap_hauler.yaml!"

  echo -e "\nStoring images in the Hauler store. This will take some time..."
  runSSHOutput "${REGISTRY_FQDN}" "hauler store sync -f /opt/hauler/airgap_hauler.yaml"

  echo -e "\nStarting the registry server in the background. This will take ~10 minutes to fully load all the images..."
  runSSH "${REGISTRY_FQDN}" "hauler store serve registry &>/dev/null &"
  echo -e "\nSleeping for 10 minutes..."
  sleep 600
}

rancher() {   
  echo -e "\nDeploying cert-manager..."
  helm upgrade -i cert-manager oci://${REGISTRY_FQDN}:5000/hauler/cert-manager --version "${CERT_VERSION}" --namespace cert-manager --create-namespace --set crds.enabled=true --plain-http
    
  echo -e "\nDeploying Rancher..."
  helm upgrade -i rancher oci://${REGISTRY_FQDN}:5000/hauler/rancher --namespace cattle-system --create-namespace --set bootstrapPassword=${BOOTSTRAP_PASSWORD} --set replicas=1 --set auditLog.level=2 --set auditLog.destination=hostPath --set useBundledSystemChart=true --set hostname=${FQDN} --plain-http
    
  echo -e "\nUpdating ingress..."
  kubectl patch ingress rancher -n cattle-system --type=json -p='[{"op": "add", "path": "/spec/rules/-", "value": {"host": '${INTERNAL_FQDN}',"http":{"paths":[{"backend":{"service":{"name":"rancher","port":{"number":80}}},"pathType":"ImplementationSpecific"}]}}}]'
  kubectl patch ingress rancher -n cattle-system --type=json -p='[{"op": "add", "path": "/spec/tls/0/hosts/-", "value": '${INTERNAL_FQDN}'}]'
    
  echo -e "\nWaiting a minute to update the server URL..."
  sleep 60
  kubectl patch setting server-url --type=json -p='[{"op": "add", "path": "/value", "value": 'https://${INTERNAL_FQDN}'}]'
    
  cat <<EOF

--------------------------------------------------------------
Instructions to deploy downstream RKE1 clusters
--------------------------------------------------------------
When deploying downstream RKE1 clusters, ensure that each node has the following specified in /etc/docker/daemon.json:
{
  "insecure-registries": ["${REGISTRY_IP}:5000"]
}

Then, run the following command: sudo systemctl daemon-reload && sudo systemctl restart docker.

In Rancher, the private registry section should have only the URL section filled out to: ${REGISTRY_IP}:5000

--------------------------------------------------------------
Instructions to deploy downstream RKE2/K3s clusters
--------------------------------------------------------------
When deploying downstream RKE2/K3s clusters, ensure that the YAML looks like the following:
registries:
  configs:
    ${REGISTRY_IP}:
      insecureSkipVerify: true
  mirrors:
    docker.io:
      endpoint:
        - http://${REGISTRY_IP}:5000
EOF
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

setupRKE2RPM() {
  export RKE2_MINOR="30"
  export LINUX_MAJOR="8"

  sudo tee /etc/yum.repos.d/rancher-rke2-1-${RKE2_MINOR}-latest.repo > /dev/null << EOF
[rancher-rke2-common-latest]
name=Rancher RKE2 Common Latest
baseurl=https://rpm.rancher.io/rke2/latest/common/centos/${LINUX_MAJOR}/noarch
enabled=1
gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key

[rancher-rke2-1-${RKE2_MINOR}-latest]
name=Rancher RKE2 1.${RKE2_MINOR} Latest
baseurl=https://rpm.rancher.io/rke2/latest/1.${RKE2_MINOR}/centos/${LINUX_MAJOR}/x86_64
enabled=1
gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key
EOF
}

kernelSettings() {
  echo -e "\nUpdating kernel settings..."

  sudo tee /etc/sysctl.conf > /dev/null << EOF
# SWAP settings
vm.swappiness=0
vm.panic_on_oom=0
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
vm.max_map_count = 262144

# Have a larger connection range available
net.ipv4.ip_local_port_range=1024 65000

# Increase max connection
net.core.somaxconn=10000

# Reuse closed sockets faster
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15

# The maximum number of "backlogged sockets".  Default is 128.
net.core.somaxconn=4096
net.core.netdev_max_backlog=4096

# 16MB per socket - which sounds like a lot,
# but will virtually never consume that much.
net.core.rmem_max=16777216
net.core.wmem_max=16777216

# Various network tunables
net.ipv4.tcp_max_syn_backlog=20480
net.ipv4.tcp_max_tw_buckets=400000
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_wmem=4096 65536 16777216

# ARP cache settings for a highly loaded docker swarm
net.ipv4.neigh.default.gc_thresh1=8096
net.ipv4.neigh.default.gc_thresh2=12288
net.ipv4.neigh.default.gc_thresh3=16384

# ip_forward and tcp keepalive for iptables
net.ipv4.tcp_keepalive_time=600
net.ipv4.ip_forward=1

# monitor file system events
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
EOF

  sudo sysctl -p > /dev/null 2>&1
}

usage() {
	cat << EOF

$(basename "$0")

======================================================
      Setup Air-gapped Rancher using Hauler
======================================================
This script will deploy an air-gapped Rancher using Hauler.
-------------------------------------------------------------

This script will deploy an air-gapped Rancher Server using Hauler on top of an RKE2 cluster. You will need the

following:

    * 5 RHEL VMs - 1 client node, 1 registry, 1 control plane nodes, 2 agent nodes
         * Terraform needs to already be installed on the client node
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
    preReqs
    setupControlPlane
    setupAgent
    setupRegistry
    rancher
}

Main "$@"