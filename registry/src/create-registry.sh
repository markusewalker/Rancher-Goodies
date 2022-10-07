#!/usr/bin/bash

# Authored By   : Markus Walker
# Date Modified : 10/6/22

# Description   : To create a private registry using Docker and to load Rancher images into the registry.

if [[ $EUID -ne 0 ]]; then
    echo -e "\nThis script must be run as the root user."
    exit 1
fi

setupAuth() {
    echo -e "\nSetting up htpasswd..."
    mkdir -p auth
    htpasswd -Bbn "${REGISTRY_USER}" "${REGISTRY_PASS}" > auth/htpasswd
}

createCert() {
    echo -e "\nCreating a self-signed certificate..."
    mkdir -p certs
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -addext "subjectAltName = DNS:${HOST}" -x509 -days 365 -out certs/domain.crt -subj "/C=US/ST=CA/L=SUSE/O=Dis/CN=${HOST}"

    echo -e "\nCopying the certificate to the /etc/docker/certs.d/${HOST} directory..."
    mkdir -p /etc/docker/certs.d/"${HOST}"
    cp certs/domain.crt /etc/docker/certs.d/"${HOST}"/ca.crt
}

createRegistry() {
    echo -e "\nCreating a private registry..."
    docker run -d --restart=always --name "${REGISTRY}" -v `pwd`/auth:/auth -v `pwd`/certs:/certs -v `pwd`/certs:/certs \
                                                                                                  -e REGISTRY_AUTH=htpasswd \
                                                                                                  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
                                                                                                  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
                                                                                                  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
                                                                                                  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
                                                                                                  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
                                                                                                  -p 443:443 \
                                                                                                  registry:2
}

loginRegistry() {
    echo -e "\nLogging into the private registry..."
    docker login "https://${HOST}" -u "${REGISTRY_USER}" -p "${REGISTRY_PASS}"
}

saveAndLoadImages() {
    echo -e "\nDownloading "${RANCHER_VERSION}" image list and scripts..."
    wget https://github.com/rancher/rancher/releases/download/"${RANCHER_VERSION}"/rancher-images.txt
    wget https://github.com/rancher/rancher/releases/download/"${RANCHER_VERSION}"/rancher-save-images.sh
    wget https://github.com/rancher/rancher/releases/download/"${RANCHER_VERSION}"/rancher-load-images.sh
    
    echo -e "\nEditing the downloaded scripts..."
    sed -i '58d' rancher-save-images.sh && \
    sed -i '76d' rancher-load-images.sh && \
    chmod +x rancher-save-images.sh && chmod +x rancher-load-images.sh
    
    echo -e "\nSaving the images..."
    ./rancher-save-images.sh --image-list ./rancher-images.txt

    echo -e "\nLoading the images to the "${REGISTRY_NAME}"..."
    ./rancher-load-images.sh --image-list ./rancher-images.txt --registry "${HOST}"
}

usage() {
	cat << EOF

$(basename "$0")

This script will create a private registry using Docker. This script assumes you have the following
tools installed on the system:

    * Docker
    * htpasswd

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
    echo -e "\x1B[96m====================================================="
    echo -e "\tCreate Private Registry using Docker"
    echo -e "====================================================="
    echo -e "This script will create a private registry using Docker and load up Rancher images."
    echo -e "-----------------------------------------------------------------------------------\x1B[0m"

    export REGISTRY_USER=""
    export REGISTRY_PASS=""
    export REGISTRY_NAME=""
    export HOST=""
    export RANCHER_VERSION=""

    setupAuth
    createCert
    createRegistry
    loginRegistry
    saveAndLoadImages
}

Main "$@"
