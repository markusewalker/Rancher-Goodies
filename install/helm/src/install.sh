#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 2/2/23

# Description   : To deploy Rancher on using Helm.

installDebianDocker() {
    echo -e "\nInstalling Docker..."
    curl https://releases.rancher.com/install-docker/20.10.sh | sh

    echo -e "\nSetting sudo privileges to root user and Rancher user..."
    sudo usermod -aG docker root
    sudo usermod -aG docker ${USER}
}

installFedoraDocker() {
    echo -e "\nInstalling Docker..."
    sudo dnf install dnf-plugins-core -y
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io -y

    sudo systemctl enable docker
    sudo systemctl start docker

    echo -e "\nSetting sudo privileges to root user and Rancher user..."
    sudo usermod -aG docker root
    sudo usermod -aG docker ${USER}
}

installRockyDocker() {
    echo -e "\nInstalling Docker..."
    sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf update -y
    sudo dnf install -y docker-ce docker-ce-cli containerd.io

    sudo systemctl enable docker
    sudo systemctl start docker

    echo -e "\nSetting sudo privileges to root user and Rancher user..."
    sudo usermod -aG docker root
    sudo usermod -aG docker ${USER}
}

installSUSEDocker() {
    echo -e "\nUpdating CA-certificates..."
    sudo update-ca-certificates
    sudo zypper ref -s

    echo -e "\nInstalling Docker..."
    sudo update-ca-certificates
    sudo zypper ref -s

    [[ "${ID}" == "opensuse-leap" ]] && sudo zypper addrepo https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Leap_15.4/Virtualization:containers.repo
    [[ "${ID}" == "sles" ]] && sudo zypper addrepo https://download.opensuse.org/repositories/security:SELinux/15.4/security:SELinux.repo
    
    sudo zypper ref -s
    sudo zypper install -y docker

    sudo systemctl enable docker
    sudo usermod -G docker -a root
    sudo usermod -aG docker ${USER}
    sudo systemctl start docker
}

setupK8s() {
    echo -e "\nInstalling kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    mkdir -p ~/.kube
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
    sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
    sudo chown $(id -u):$(id -g) -R $HOME/.kube/config

    echo -e "\nAdding Helm chart repo..."
    helm repo add ${REPO} https://releases.rancher.com/server-charts/${TYPE}

    echo -e "\nCreating cattle-system namespace..."
    kubectl create ns cattle-system

    echo -e "\nInstalling cert-manager..."
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version ${CERT_MANAGER_VERSION}

    echo -e "\nVerifying cert-manager has been properly setup..."
    kubectl get pods --namespace cert-manager  
}

installRancher() {
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

    export REPO=""
    export TYPE=""
    export NAME=""
    export USER=""
    export UI_PASSWORD=""
    export CERT_MANAGER_VERSION=""

    . /etc/os-release

    [[ "${ID}" == "ubuntu" || "${ID}" == "debian" ]] && installDebianDocker
    [[ "${ID}" == "rhel" || "${ID}" == "fedora" ]] && installFedoraDocker
    [[ "${ID}" == "rocky" ]] && installRockyDocker
    [[ "${ID}" == "opensuse-leap" || "${ID}" == "sles" ]] && installSUSEDocker
    
    setupK8s
    installHelm
    setupPreqs
    installRancher
}

Main "$@"