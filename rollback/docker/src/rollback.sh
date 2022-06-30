#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 6/29/22

# Description   : To rollback Rancher using Docker.

rollbackRancher() {
    echo -e "\nStopping Rancher..."
    docker stop "${CONTAINER_ID}"

    echo -e "\nPulling old Rancher image..."
    docker pull "${ROLLBACK_IMAGE_TAG}"

    echo -e "\nReplacing data in ${DATA_CONTAINER} with the data in ${BACKUP}..."
    docker run --volumes-from "${DATA_CONTAINER}" -v ${PWD}:/backup busybox sh -c "rm ${VARLIB}/* -rf && tar zxvf ${BACKUP}"

    echo -e "\nStarting Rancher..."
    docker run -d --volumes-from "${DATA_CONTAINER}" --restart=unless-stopped -p 80:80 -p 443:443 --privileged "${ROLLBACK_IMAGE_TAG}"
}

usage() {
	cat << EOF

$(basename "$0")

This script will rollback Rancher API Server using Docker. This script assumes that you already have Rancher up and

running. You will need to either be the root user or the user that installed Rancher. You will be prompted for the

following information:

    - Current version of Rancher
    - Version you wish to rollback to

Additionally, this script assumes that you are using a self-signed certificate.

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
    echo -e "\tRollback Rancher using Docker"
    echo -e "=================================================="
    echo -e "This script will rollback Rancher using Docker."
    echo -e "-----------------------------------------------\x1B[0m"
    
    read -p "Enter in the version of Rancher to rollback to (i.e. v2.6.5): " ROLLBACK_VERSION

    export RANCHER="rancher/rancher"
    export ROLLBACK_IMAGE_TAG="${RANCHER}:$ROLLBACK_VERSION"
    export CONTAINER_ID=`docker ps | awk 'NR > 1 {print $1}'`
    export DATA_CONTAINER="rancher-data"
    export VARLIB="/var/lib/rancher"
    export BACKUP="/backup/${DATA_CONTAINER}-${ROLLBACK_VERSION}.tar.gz"

    rollbackRancher
}

Main "$@"
