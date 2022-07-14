#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 7/14/22

# Description   : To deploy Rancher on using Helm.

if [[ $(id -u) -ne 0 ]];
then
   echo "ERROR. Run script as the root user!" 2>&1
   exit 1
fi

installDebianDocker() {
    echo -e "\nInstalling Docker..."
    curl https://releases.rancher.com/install-docker/20.10.sh | sh

    echo -e "\nSetting sudo privileges to root user..."
    sudo usermod -aG docker root
}

installFedoraDocker() {
    echo -e "\nInstalling Docker..."
    sudo dnf install dnf-plugins-core -y
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io -y

    sudo systemctl enable docker
    sudo systemctl start docker

    echo -e "\nSetting sudo privileges to root user..."
    sudo usermod -aG docker root
}

installSUSEDocker() {
    echo -e "\nUpdating CA-certificates..."
    sudo update-ca-certificates
    sudo zypper ref -s

    echo -e "\nInstalling Docker..."
    sudo zypper addrepo https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Leap_15.3/Virtualization:containers.repo
    sudo zypper ref -s
    sudo zypper install -y docker
    sudo systemctl enable docker
    sudo usermod -G docker -a root
    sudo systemctl restart docker
}

debianK8s() {
    echo -e "\nInstalling required packages..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl

    echo -e "\nDownloading Google Cloud public signing key..."
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

    echo -e "\nAdding K8s repoistory..."
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    echo -e "\nInstalling kubelet, kubeadm, kubectl..."
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
}

fedoraK8s() {
    echo -e "\nAdding K8s repoistory..."
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

    echo -e "\nSetting SELinux to permissive mode..."
    sudo setenforce 0
    sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

    echo -e "\nInstall kubelet, kubeadm, kubectl..."
    sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    sudo systemctl enable --now kubelet
}

suseK8s() {
    echo -e "\nInstalling kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
}

installHelm() {
    echo -e "\nInstalling Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod +x get_helm.sh
    ./get_helm.sh

    echo -e "\nVerifying Helm is installed..."
    helm version

    echo -e "\nCleaning up..."
    rm get_helm.sh
}

setupPreqs() {
    echo -e "\nInstalling K3s cluster..."
    curl -sfL https://get.k3s.io | sh -s - server

    echo -e "\nCopying over kubeconfig file..."
    mkdir -p $HOME/.kube
    cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config

    echo -e "\nAdding Helm chart repo..."
    helm repo add ${REPO} https://releases.rancher.com/server-charts/stable

    echo -e "\nCreating cattle-system namespace..."
    kubectl create ns cattle-system

    echo -e "\nInstalling cert-manager..."
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.1

    echo -e "\nVerifying cert-manager has been properly setup..."
    kubectl get pods --namespace cert-manager  
}

installRancher() {
    read -p "Enter in the password to login to Rancher: " UI_PASSWORD

    echo -e "\nInstalling Rancher..."
    helm install rancher $REPO/rancher --namespace cattle-system \
                                       --set hostname=$NAME \
                                       --set bootstrapPassword=${UI_PASSWORD}

    echo -e "\nWaiting for Rancher to be rolled out..."
    kubectl -n cattle-system rollout status deploy/rancher

    echo -e "\nVerifying Rancher was successfully deployed..."
    kubectl -n cattle-system get deploy rancher
}

usage() {
	cat << EOF

$(basename "$0")

This script will deploy Rancher API Server to a machine using Helm. You will need to be the root user.

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
    esac
done

Main() {
    echo -e "\x1B[96m=============================================="
    echo -e "\tSetup Rancher using Helm"
    echo -e "=============================================="
    echo -e "This script will deploy Rancher using Helm."
    echo -e "---------------------------------------------\x1B[0m"

    export REPO="rancher-stable"
    read -p "Enter in the FQDN of your client machine: " NAME

    . /etc/os-release

    if [[ "${ID}" == "ubuntu" || "${ID}" == "debian" ]]; then
        installDebianDocker
        debianK8s
    elif [[ "${ID}" == "rhel" || "${ID}" == "fedora" ]]; then
        installFedoraDocker
        fedoraK8s
    elif [[ "${ID}" == "opensuse-leap" ]]; then
        installSUSEDocker
        suseK8s
    fi
    
    installHelm
    setupPreqs
    installRancher
}

Main "$@"