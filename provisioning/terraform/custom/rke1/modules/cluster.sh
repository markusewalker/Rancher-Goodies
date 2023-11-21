#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 11/9/23

# Description   : To provision a RKE1 custom cluster using Terraform.

createCluster() {
    echo -e "\nInitializing Terraform for creating custom cluster..."
    cd "${CREATEDIR}"
    terraform init

    echo -e "\nCreating K3S cluster..."
    terraform apply --auto-approve

}

registerNodes() {
    export TF_VAR_registration_command=$(terraform output cluster_registration_token | grep "node_command" | awk '{$1= ""; $2= ""; $3= ""; print $0}')
    export TF_VAR_registration_command=$(echo "${TF_VAR_registration_command}" | sed 's/-NoLogo.*//g')
    export TF_VAR_registration_command=$(echo "${TF_VAR_registration_command}" | sed 's/\"//g')
    export TF_VAR_registration_command=$(echo "${TF_VAR_registration_command}" | sed 's/ *$//g')

    echo -e "\nInitializing Terraform for registering nodes..."
    cd "../${NODEDIR}"
    terraform init

    echo -e "\nRegistering nodes..."
    terraform apply --auto-approve
}

usage() {
	cat << EOF

$(basename "$0")

This script will provision a custom RKE1 cluster to Rancher using Terraform. You must meet the following requirements:

    * Terraform must be installed
    * Rancher server
    * Filled out Terraform files in the createCluster and registerNode directories
    * Specified AMI has Docker installed + permissions granted to the desired user

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
    echo -e "\tProvision Custom RKE1 Cluster"
    echo -e "=================================================="
    echo -e "This script will provision a custom RKE1 custom cluster using Terraform."
    echo -e "------------------------------------------------------------------------\x1B[0m"

    export CREATEDIR="createCluster"
    export NODEDIR="registerNodes"
    
    createCluster
    registerNodes
}

Main "$@"
