#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 7/14/22

# Description   : To upgrade Rancher using Helm.

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

upgradeRancher() {
    echo -e "\nUpdating the Helm repo..."
    helm repo update

    echo -e "\Verifying the list is populated..."
    helm repo list

    echo =-e "\nFetch the updated Helm repo..."
    helm fetch ${REPO}/rancher
   
    echo -e "\nUpgrading Rancher..."
    helm upgrade rancher $REPO/rancher -n cattle-system --version=${VERSION} \
        --set hostname=$NAME \
        --set ingress.tls.source=secret \
        --set rancherImageTag=${TAG} \
        --set bootstrapPassword=${UI_PASSWORD}
}

usage() {
	cat << EOF

$(basename "$0")

This script will upgrade Rancher API Server to a machine using Helm. You need to be the user 

that deployed Rancher.

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
    echo -e "\t\Upgrade Rancher using Helm"
    echo -e "=============================================="
    echo -e "This script will upgrade Rancher using Helm."
    echo -e "---------------------------------------------\x1B[0m"

    export REPO="rancher-stable"

    read -p "Enter the FQDN of the Rancher host: " NAME
    read -p "Enter the password for the Rancher UI: " UI_PASSWORD
    read -p "Enter the version of Rancher to upgrade to: " VERSION
    read -p "Enter the tag of the Rancher image to upgrade to (e.g. v2.6-head): " TAG

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
    upgradeRancher
}

Main "$@"