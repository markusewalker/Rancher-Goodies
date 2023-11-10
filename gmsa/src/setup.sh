#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 11/10/23

# Description   : To deploy Rancher with Windows gMSA.

setupRepos() {
    echo -e "\nCloning the rancher/windows repo..."
    git clone git@github.com:rancher/windows.git
    cd windows
    
    echo -e "\nSetting up repos..."
    terraform -chdir=terraform/azure_docker_rancher init
    terraform -chdir=terraform/azure_active_directory init
    terraform -chdir=terraform/azure_rke2_cluster init
}

setupAzureAD() {
    echo -e "\nSetting up Azure Active Directory..."
    terraform -chdir=terraform/azure_active_directory apply --auto-approve -var="name=${TF_NAME_PREFIX}-ad"

    echo -e "\nSleeping for 12 minutes to allow Azure AD to finish setting up..."
    sleep ${SLEEP_TIME}
}

setupRancher() {
    echo -e "\nSetting up Rancher..."
    terraform -chdir=terraform/azure_docker_rancher apply --auto-approve -var="name=${TF_NAME_PREFIX}-rancher"

    terraform -chdir=terraform/azure_docker_rancher output | grep "ssh -i ~/.ssh/id_rsa adminuser" | awk -F'"' '{print $1}' > kubeconfig_cmd.txt
    rancher_cmd=$(cat kubeconfig_cmd.txt)
    bash <<RANCHERCMD
    ${rancher_cmd}
RANCHERCMD
}

setupCluster() {
    echo -e "\nExporting the Rancher kubeconfig..."
    export KUBECONFIG=$(pwd)/${TF_NAME_PREFIX}-rancher.kubeconfig

    echo -e "\nSetting up Azure AD integration..."
    setup_active_directory_integration=$(terraform -chdir=terraform/azure_active_directory output -raw setup_integration)
bash <<TFOUTPUT
${setup_active_directory_integration}
TFOUTPUT

    echo -e "\nSetting up RKE2 cluster..."
    setup_active_directory_terraform_integration=$(terraform -chdir=terraform/azure_active_directory output -raw setup_terraform)

    cp ../gmsa.tfvars terraform/azure_rke2_cluster/examples
    cp ../gmsa_dj.tfvars terraform/azure_rke2_cluster/examples
    terraform -chdir=terraform/azure_rke2_cluster apply --auto-approve -var-file="examples/gmsa.tfvars" -var="name=${TF_NAME_PREFIX}-cluster" ${setup_active_directory_terraform_integration}
}

usage() {
	cat << EOF

$(basename "$0")

This script will deploy Rancher with Windows gMSA. The script takes advantage of the rancher/windows repo's Terraform

scripts for setting up the following resources:

    * Azure Active Directory
    * Rancher server (Azure-based)
    * Windows RKE2 cluster (Azure-based)

Additionally, this script assumes that you have the following tools installed and configured:
    
        * Terraform
        * Azure CLI
        * Git

USAGE: % ./$(basename "$0") <name prefix> [options]

OPTIONS:
	-h	-> Usage

EXAMPLES OF USAGE:

* Run script
	
	$ ./$(basename "$0") name-prefix

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
    echo -e "\tSetup Rancher w/gMSA"
    echo -e "=================================================="
    echo -e "This script will deploy Rancher with Windows gMSA."
    echo -e "---------------------------------------------------\x1B[0m"

    export TF_NAME_PREFIX="$1"
    export SLEEP_TIME="720"
    
    setupRepos
    setupAzureAD
    setupRancher
    setupCluster
}

Main "$@"
