#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 1/31/23

# Description   : To upgrade Rancher using Helm.

upgradeRancher() {
    echo -e "\nUpdating the Helm repo..."
    helm repo update

    echo -e "\nVerifying the list is populated..."
    helm repo list

    echo -e "\nFetch the updated Helm repo..."
    helm fetch rancher-latest/rancher
   
    echo -e "\nUpgrading Rancher..."
    helm upgrade rancher rancher-latest/rancher -n cattle-system --version=${VERSION} --set hostname=$NAME \
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
    echo -e "\x1B[96m=================================================="
    echo -e "\t\Upgrade Rancher using Helm"
    echo -e "=================================================="
    echo -e "This script will upgrade Rancher using Helm."
    echo -e "---------------------------------------------\x1B[0m"

    export NAME=""
    export UI_PASSWORD=""
    export VERSION=""
    export TAG=""
    
    upgradeRancher
}

Main "$@"