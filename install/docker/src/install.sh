#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 4/12/22

# Description   : To deploy Rancher using Docker.

installDebianDocker() {
    echo -e "\nInstalling Docker..."
    curl https://releases.rancher.com/install-docker/20.10.sh | sh

    echo -e "\nSetting sudo privileges to root user and Rancher user..."
    sudo usermod -aG docker root
    sudo usermod -aG docker linux
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
    sudo usermod -aG docker linux
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
    sudo usermod -aG docker linux
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
    sudo usermod -G docker -a linux
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

startRancher() {
    read -p "Enter in the name of the password you wish to use for Rancher: " UI_PASSWORD
    echo -e "\nStarting Rancher up..."

    export RVERSION="v2.6-head"
    sudo docker run -d -e "CATTLE_BOOTSTRAP_PASSWORD=${UI_PASSWORD}" --restart unless-stopped -p 80:80 -p 443:443 --privileged "rancher/rancher:${RVERSION}"
}

usage() {
	cat << EOF

$(basename "$0")

This script will deploy Rancher API Server to a machine using Docker. You need to be the user that will deploy Rancher.

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
    echo -e "\x1B[96m=================================================="
    echo -e "\tSetup Rancher using Docker"
    echo -e "=================================================="
    echo -e "This script will deploy Rancher using Docker."
    echo -e "---------------------------------------------\x1B[0m"

    . /etc/os-release

    if [[ "${ID}" == "ubuntu" || "${ID}" == "debian" ]]; then
        installDebianDocker
        debianK8s
    elif [[ "${ID}" == "rhel" || "${ID}" == "fedora" ]]; then
        installFedoraDocker
        fedoraK8s
    elif [[ "${ID}" == "rocky" ]]; then
        installRockyDocker
        fedoraK8s
    elif [[ "${ID}" == "opensuse-leap" ]]; then
        installSUSEDocker
        suseK8s
    fi
    
    startRancher
}

Main "$@"
