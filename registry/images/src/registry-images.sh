#!/bin/bash

export SSH_KEY=""
export PEM=""
export USER=""
export REGISTRY=""
export WEBHOOK_IMAGE=""
export SUC_IMAGE=""
export SYSTEM_AGENT_IMAGE=""

if [ "${EUID}" -ne 0 ]; then
  echo -e "Please run as the root user!"
  exit 1
fi

pullImages() {
  echo -e "Pulling images..."
  runSSHOutput "${REGISTRY}" "sudo docker pull $WEBHOOK_IMAGE"
  runSSHOutput "${REGISTRY}" "sudo docker pull $SUC_IMAGE"
  runSSHOutput "${REGISTRY}" "sudo docker pull $SYSTEM_AGENT_IMAGE"
}

tagImages() {
  echo -e "\nTagging images..."
  runSSHOutput "${REGISTRY}" "sudo docker tag $WEBHOOK_IMAGE $REGISTRY/$WEBHOOK_IMAGE"
  runSSHOutput "${REGISTRY}" "sudo docker tag $SUC_IMAGE $REGISTRY/$SUC_IMAGE"
  runSSHOutput "${REGISTRY}" "sudo docker tag $SYSTEM_AGENT_IMAGE $REGISTRY/$SYSTEM_AGENT_IMAGE"
}

pushImages() {
  echo -e "\nPushing images..."
  runSSHOutput "${REGISTRY}" "sudo docker push $REGISTRY/$WEBHOOK_IMAGE"
  runSSHOutput "${REGISTRY}" "sudo docker push $REGISTRY/$SUC_IMAGE"
  runSSHOutput "${REGISTRY}" "sudo docker push $REGISTRY/$SYSTEM_AGENT_IMAGE"
}

runSSHOutput() {
  local server="$1"
  local cmd="$2"
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${SSH_KEY}" "${USER}@${server}" "${cmd}"
}

usage() {
	cat << EOF

$(basename "$0")

======================================================
             Pull, Tag, and Push Images
======================================================
This script will pull, tag and push images to a private registry.

Please have the following:

    * PEM file to ssh into the nodes
    * Run as root

Be sure to run this script on the client node as the root user.

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
    *)
      echo "Invalid option. Valid option(s) are [-h]." 2>&1
			exit 1;;
  esac
done

Main() {
    pullImages
    tagImages
    pushImages
}

Main "$@"