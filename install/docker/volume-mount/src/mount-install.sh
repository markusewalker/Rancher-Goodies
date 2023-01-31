#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 1/31/23

# Description   : To deploy Rancher using Docker with volume mounts.

installDebianDocker() {
    echo -e "\nInstalling Docker..."
    curl https://releases.rancher.com/install-docker/20.10.sh | sh

    echo -e "\nSetting sudo privileges to root user and Rancher user..."
    sudo usermod -aG docker root
    sudo usermod -aG docker $(whoami)
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
    sudo usermod -aG docker $(whoami)
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
    sudo usermod -aG docker $(whoami)
}

installSUSEDocker() {
    echo -e "\nUpdating CA-certificates..."
    sudo update-ca-certificates
    sudo zypper ref -s

    echo -e "\nInstalling Docker..."
    if [[ "${ID}" == "opensuse-leap" ]]; then
        sudo zypper addrepo https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Leap_15.4/Virtualization:containers.repo
        sudo zypper ref -s
        sudo zypper install -y docker
    else [[ "${ID}" == "sles" ]]
        sudo zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo
        sudo zypper install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi
    
    sudo systemctl enable docker
    sudo usermod -G docker -a root
    sudo usermod -aG docker $(whoami)
    sudo systemctl restart docker
}

setupK8s() {
    echo -e "\nInstalling kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    mkdir -p ~/.kube
    rm kubectl
}

startRancher() {
    echo -e "\nStarting Rancher up..."
    sudo docker run -d -e "CATTLE_BOOTSTRAP_PASSWORD=${UI_PASSWORD}" --restart unless-stopped \
                                                                     -v /opt/rancher/var/lib/rancher:/var/lib/rancher \
                                                                     -v /opt/rancher/var/log:/var/log \
                                                                     -v /opt/rancher/var/lib/cni:/var/lib/cni \
                                                                     -v /opt/rancher/var/lib/kubelet:/var/lib/kubelet \
                                                                     -p 80:80 -p 443:443 \
                                                                     --privileged "rancher/rancher:${RVERSION}"
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

    export RVERSION="v2.7-head"
    export UI_PASSWORD="testingrancherout"

    . /etc/os-release

    [[ "${ID}" == "ubuntu" || "${ID}" == "debian" ]] && installDebianDocker
    [[ "${ID}" == "rhel" || "${ID}" == "fedora" ]] && installFedoraDocker
    [[ "${ID}" == "rocky" ]] && installRockyDocker
    [[ "${ID}" == "opensuse-leap" || "${ID}" == "sles" ]] && installSUSEDocker
    
    setupK8s
    startRancher
}

Main "$@"
