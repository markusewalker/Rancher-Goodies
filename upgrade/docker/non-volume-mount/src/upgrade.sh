#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 6/29/22

# Description   : To upgrade Rancher using Docker.

upgradeRancher() {
    echo -e "\nStopping Rancher and creating a data container..."
    docker stop "${CONTAINER_ID}"
    docker create --volumes-from "${CONTAINER_ID}" --name "${DATA_CONTAINER}" "${OLD_IMAGE_TAG}"

    echo -e "\nCreating a backup tarball..."
    docker run --volumes-from "${DATA_CONTAINER}" -v "${PWD}:/backup" --rm busybox tar zcvf "${BACKUP}" "${VARLIB}"

    echo -e "\nPulling new Rancher image..."
    docker pull "${NEW_IMAGE_TAG}"

    echo -e "\nStarting Rancher..."
    docker run -d --volumes-from "${DATA_CONTAINER}" --restart=unless-stopped \
                                                     -p 80:80 -p 443:443 \
                                                     --privileged "${NEW_IMAGE_TAG}"
}

usage() {
	cat << EOF

$(basename "$0")

This script will upgrade Rancher API Server using Docker. This script assumes that you already have Rancher up and

running. You will need to either be the root user or the user that installed Rancher. You will be prompted for the

following information:

    - Current version of Rancher
    - Version you wish to upgrade to

Additionally, this script assumes that you are using a self-signed certificate.

USAGE: % ./$(basename "$0") [options]

OPTIONS:
	-h	-> Usage

EXAMPLES OF USAGE:

* Run script
	
	$ ./$(basename "$0")

EOF
}

# Get flags to run the script silently.
while getopts "h" opt; do
	case ${opt} in
		h)
			usage
			exit 0;;
    esac
done

Main() {
    echo -e "\x1B[96m=================================================="
    echo -e "\tUpgrade Rancher using Docker"
    echo -e "=================================================="
    echo -e "This script will upgrade Rancher using Docker."
    echo -e "-----------------------------------------------\x1B[0m"
    
    read -p "Enter in the version of the current Rancher (i.e. v2.6.5): " OLD_VERSION
    read -p "Enter in the version of Rancher to upgrade to (i.e. v2.6.6): " NEW_VERSION

    export RANCHER="rancher/rancher"
    export OLD_IMAGE_TAG="${RANCHER}:${OLD_VERSION}"
    export NEW_IMAGE_TAG="${RANCHER}:${NEW_VERSION}"
    export CONTAINER_ID=`docker ps | awk 'NR > 1 {print $1}'`
    export DATA_CONTAINER="rancher-data"
    export VARLIB="/var/lib/rancher"
    export BACKUP="/backup/${DATA_CONTAINER}-${OLD_VERSION}.tar.gz"

    upgradeRancher
}

Main "$@"
