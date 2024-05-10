#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 10/26/22

# Description   : To populate ECR with Rancher images.

loginECR() {
    echo -e "\nLogging into ECR..."
    aws ecr get-login-password --region ${REGION} | docker login --username "${USERNAME}" --password-stdin "${ECR}"
}

createCert() {
    echo -e "\nCreating a self-signed certificate..."
    mkdir -p certs
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -addext "subjectAltName = DNS:${ECR}" -x509 -days 365 -out certs/domain.crt -subj "/C=US/ST=CA/L=SUSE/O=Dis/CN=${ECR}"

    echo -e "\nCopying the certificate to the /etc/docker/certs.d/${ECR} directory..."
    sudo mkdir -p /etc/docker/certs.d/"${ECR}"
    sudo cp certs/domain.crt /etc/docker/certs.d/"${ECR}"/ca.crt
}

createECRRepo() {
    echo -e "\nDownloading "${RANCHER_VERSION}" image list and scripts..."
    wget https://github.com/rancher/rancher/releases/download/"${RANCHER_VERSION}"/rancher-images.txt
    wget https://github.com/rancher/rancher/releases/download/"${RANCHER_VERSION}"/rancher-save-images.sh

    echo -e "\nCutting the tags from the image names..."
    while read LINE; do
        echo ${LINE} | cut -d: -f1
    done < rancher-images.txt > rancher-images-no-tags.txt

    echo -e "\nCreating ECR repositories..."
    for IMAGE in $(cat rancher-images-no-tags.txt); do
        aws ecr create-repository --repository-name ${IMAGE}
    done
}

saveAndLoadImages() {
    echo -e "\nSaving the images..."
    sed -i '' 's/echo "Creating/#echo "Creating/g' rancher-save-images.sh
    sed -i '' 's/docker save/#docker save/g' rancher-save-images.sh
    ./rancher-save-images.sh --image-list ./rancher-images.txt

    echo -e "\nTagging the images..."
    for IMAGE in $(cat rancher-images.txt); do
        docker tag ${IMAGE} "${ECR}"/${IMAGE}
    done

    echo -e "\Pushing the newly tagged images ECR..."
    for IMAGE in $(cat rancher-images.txt); do
        docker push "${ECR}"/${IMAGE}
    done
}

usage() {
	cat << EOF

$(basename "$0")

This script will populate a private ECR with Rancher images. This script assumes you have the following
tools installed and configured on the system:

    * Docker
    * AWS CLI

The user running this script will need sudo privleges to avoid having to enter a password for sudo.

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
    echo -e "\x1B[96m========================================================"
    echo -e "\tPopulate Private ECR with Rancher Images"
    echo -e "========================================================"
    echo -e "This script will populate a private ECR with Rancher imagess."
    echo -e "--------------------------------------------------------------\x1B[0m"

    export AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id)"
    export AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key)"
    export REGION="$(aws configure get region)"
    export USERNAME=""
    export ECR=""
    export RANCHER_VERSION=""

    loginECR
    createCert
    createECRRepo
    saveAndLoadImages
}

Main "$@"