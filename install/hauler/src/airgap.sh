#!/bin/bash

export FQDN=""
export INTERNAL_FQDN=""
export REGISTRY_IP=""
export CP_SERVER_IP=""
export WORKER1_SERVER_IP=""
export WORKER2_SERVER_IP=""
export PATH=$PATH:/usr/local/bin
export RKE2_VERSION="v1.30.3"
export CERT_VERSION="v1.15.3"
export RANCHER_VERSION="v2.9.0"
export RED="\x1B[0;31m"
export GREEN="\x1B[32m"
export BLUE="\x1B[34m"
export YELLOW="\x1B[33m"
export NO_COLOR="\x1B[0m"
export BOOTSTRAP_PASSWORD=""
export SSH_KEY=""
export USER="ec2-user"
export COMPRESSED_HAULER="hauler_airgap_$(date '+%m_%d_%y').zst"
export EL_VER=el8

if type rpm > /dev/null 2>&1 ; then export EL=${EL_VER:-$(rpm -q --queryformat '%{RELEASE}' rpm | grep -o "el[[:digit:]]" )} ; fi

if [ "$1" != "build" ] && [ $(uname) != "Darwin" ] ; then 
    export serverIp=${CP_SERVER_IP:-$(hostname -I | awk '{ print $1 }')}; 
fi

if [ $(whoami) != "root" ] && ([ "$1" = "control" ] || [ "$1" = "worker" ] || [ "$1" = "serve" ] || [ "$1" = "rancher" ]) ; then 
    fatal "Must run the script as the root user!" 
fi

build() {
  info "Installing the following required packages: sudo, openssl, hauler, zstd, rsync, jq, helm, kubectl"

  yum install sudo -y > /dev/null 2>&1
  yum install openssl -y > /dev/null 2>&1
  yum install rsync -y > /dev/null 2>&1
  yum install zstd -y > /dev/null 2>&1
  yum install epel-release -y > /dev/null 2>&1
  yum install jq createrepo -y > /dev/null 2>&1
  
  curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash  > /dev/null 2>&1
  curl -sfL https://get.hauler.dev | bash > /dev/null 2>&1
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null 2>&1
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl > /dev/null 2>&1
  mkdir -p ~/.kube
  rm kubectl

  mv /usr/local/bin/helm /usr/bin/helm > /dev/null 2>&1
  mv /usr/local/bin/hauler /usr/bin/hauler > /dev/null 2>&1
  mv /usr/local/bin/kubectl /usr/bin/kubectl > /dev/null 2>&1
  infoOK

  mkdir -p /opt/hauler
  cd /opt/hauler

  info "Creating hauler manifest..."
  mkdir -p hauler_temp

  helm repo add jetstack https://charts.jetstack.io --force-update > /dev/null 2>&1

cat << EOF > airgap_hauler.yaml
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Images
metadata:
  name: rancher-images
  annotations:
    hauler.dev/platform: linux/amd64
spec:       
  images:
EOF

  for i in $(helm template jetstack/cert-manager --version $CERT_VERSION | awk '$1 ~ /image:/ {print $2}' | sed 's/\"//g'); do 
    echo "    - name: "$i >> airgap_hauler.yaml
  done
  
  for i in $(curl -sL https://github.com/rancher/rke2/releases/download/$RKE2_VERSION%2Brke2r1/rke2-images-all.linux-amd64.txt); do 
    echo "    - name: "$i >> airgap_hauler.yaml
  done

  for i in $(curl -sL https://github.com/rancher/rancher/releases/download/$RANCHER_VERSION/rancher-images.txt); do
    echo "    - name: "$i >> airgap_hauler.yaml
  done

cat << EOF >> airgap_hauler.yaml
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Charts
metadata:
  name: rancher-charts
spec:
  charts:
    - name: rancher
      repoURL: https://releases.rancher.com/server-charts/latest
      version: $RANCHER_VERSION
    - name: cert-manager
      repoURL: https://charts.jetstack.io
      version: $CERT_VERSION
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Files
metadata:
  name: rancher-files
spec:
  files:
    - path: https://github.com/rancher/rke2-packaging/releases/download/v$RKE2_VERSION%2Brke2r1.stable.0/rke2-common-$RKE2_VERSION.rke2r1-0.$EL.x86_64.rpm
    - path: https://github.com/rancher/rke2-packaging/releases/download/v$RKE2_VERSION%2Brke2r1.stable.0/rke2-agent-$RKE2_VERSION.rke2r1-0.$EL.x86_64.rpm
    - path: https://github.com/rancher/rke2-packaging/releases/download/v$RKE2_VERSION%2Brke2r1.stable.0/rke2-server-$RKE2_VERSION.rke2r1-0.$EL.x86_64.rpm
    - path: https://github.com/rancher/rke2-selinux/releases/download/v0.17.stable.1/rke2-selinux-0.17-1.$EL.noarch.rpm
    - path: https://get.helm.sh/helm-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name)-linux-amd64.tar.gz
EOF

    echo -n "  - Created airgap_hauler.yaml"; infoOK
}

setupHauler() {
    if [ $(ss -tln | grep "8080\|5000" | wc -l) != 2 ]; then
        info "Setting up hauler..."
        curl -sfL https://get.hauler.dev | bash > /dev/null 2>&1 || fatal "Failed to Install Hauler"
        mv /usr/local/bin/hauler /usr/bin/hauler > /dev/null 2>&1

    tar -I zstd -vxf /opt/hauler/${COMPRESSED_HAULER} -C /opt/hauler > /dev/null 2>&1 || fatal "Failed to unpack hauler store"

cat << EOF > /etc/systemd/system/hauler@.service
# /etc/systemd/system/hauler.service
[Unit]
Description=Hauler Serve %I Service

[Service]
Environment="HOME=/opt/hauler/"
ExecStart=/usr/local/bin/hauler store serve %i -s /opt/hauler/store
WorkingDirectory=/opt/hauler

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload

    systemctl enable hauler@fileserver > /dev/null 2>&1 
    systemctl start hauler@fileserver || fatal "hauler fileserver did not start"
    echo -n " - fileserver started"; infoOK

    mkdir -p /opt/hauler/fileserver

    sleep 30

    systemctl enable hauler@registry > /dev/null 2>&1 
    systemctl start hauler@registry || fatal "hauler registry did not start"
    echo -n " - registry started"; infoOK

    sleep 30

    until [ $(ls -1 /opt/hauler/fileserver/ | wc -l) > 9 ]; do 
        sleep 2
    done
    
    until hauler store info > /dev/null 2>&1; do 
        sleep 5
    done

    mkdir -p /opt/hauler/fileserver
    hauler store info > /opt/hauler/fileserver/_hauler_index.txt || fatal "hauler store is having issues - check /opt/hauler/fileserver/_hauler_index.txt"

  cat << EOF > /opt/hauler/fileserver/hauler.repo
[hauler]
name=Hauler Air Gap Server
baseurl=http://$serverIp:8080
enabled=1
gpgcheck=0
EOF
  
    createrepo /opt/hauler/fileserver > /dev/null 2>&1 || fatal "createrepo did not finish correctly, please run manually `createrepo /opt/hauler/fileserver`"

    fi
}

setupOS() {
  info "Updating kernel settings..."

  cat << EOF > /etc/sysctl.conf
# SWAP settings
vm.swappiness=0
vm.panic_on_oom=0
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
vm.max_map_count = 262144

# Have a larger connection range available
net.ipv4.ip_local_port_range=1024 65000

# Increase max connection
net.core.somaxconn=10000

# Reuse closed sockets faster
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15

# The maximum number of "backlogged sockets".  Default is 128.
net.core.somaxconn=4096
net.core.netdev_max_backlog=4096

# 16MB per socket - which sounds like a lot,
# but will virtually never consume that much.
net.core.rmem_max=16777216
net.core.wmem_max=16777216

# Various network tunables
net.ipv4.tcp_max_syn_backlog=20480
net.ipv4.tcp_max_tw_buckets=400000
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_wmem=4096 65536 16777216

# ARP cache settings for a highly loaded docker swarm
net.ipv4.neigh.default.gc_thresh1=8096
net.ipv4.neigh.default.gc_thresh2=12288
net.ipv4.neigh.default.gc_thresh3=16384

# ip_forward and tcp keepalive for iptables
net.ipv4.tcp_keepalive_time=600
net.ipv4.ip_forward=1

# monitor file system events
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
EOF

sysctl -p > /dev/null 2>&1

  if yum list installed firewalld > /dev/null 2>&1; then 
    yum remove -y firewalld > /dev/null 2>&1 || fatal "firewalld could not be disabled"
    warn "firewalld was removed"
  else
    info "firewalld not installed"
  fi

  info "Disabling nm-cloud-setup..."
  systemctl disable nm-cloud-setup.service > /dev/null 2>&1
  systemctl disable nm-cloud-setup.timer > /dev/null 2>&1
  systemctl reload NetworkManager > /dev/null 2>&1

  info "Installing base packages..."
  yum install -y zstd iptables container-selinux iptables libnetfilter_conntrack libnfnetlink libnftnl policycoreutils-python-utils cryptsetup iscsi-initiator-utils > /dev/null 2>&1 || fatal "iptables container-selinux iptables libnetfilter_conntrack libnfnetlink libnftnl policycoreutils-python-utils cryptsetup iscsi-initiator-utils packages didn't install"
  systemctl enable --now iscsid > /dev/null 2>&1
  echo -e "[keyfile]\nunmanaged-devices=interface-name:cali*;interface-name:flannel*" > /etc/NetworkManager/conf.d/rke2-canal.conf

  info "Adding hauler repo..."
  curl -sfL http://$serverIp:8080/hauler.repo -o /etc/yum.repos.d/hauler.repo

  mkdir -p /etc/rancher/rke2/
  echo -e "mirrors:\n  \"*\":\n    endpoint:\n      - http://$serverIp:5000" > /etc/rancher/rke2/registries.yaml 

  yum clean all  > /dev/null 2>&1
}

setupControlPlane() {
  mkdir /opt/hauler

  info "Installing required packages zstd and createrepo..."
  yum install -y zstd > /dev/null 2>&1
  yum install -y createrepo > /dev/null 2>&1
  infoOK

  setupOS

  info "Installing RKE2 server..."
  if ! grep etcd /etc/passwd > /dev/null 2>&1 ; then 
    useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
  fi
  
  mkdir -p /etc/rancher/rke2/ /var/lib/rancher/rke2/server/manifests/ /var/lib/rancher/rke2/agent/images
  echo -e "#profile: cis-1.23\nselinux: true\nsecrets-encryption: true\ntoken: ${BOOTSTRAP_PASSWORD}\nwrite-kubeconfig-mode: 0600\nkube-controller-manager-arg:\n- bind-address=127.0.0.1\n- use-service-account-credentials=true\n- tls-min-version=VersionTLS12\n- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\nkube-scheduler-arg:\n- tls-min-version=VersionTLS12\n- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\nkube-apiserver-arg:\n- tls-min-version=VersionTLS12\n- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\n- authorization-mode=RBAC,Node\n- anonymous-auth=false\n- audit-policy-file=/etc/rancher/rke2/audit-policy.yaml\n- audit-log-mode=blocking-strict\n- audit-log-maxage=30\nkubelet-arg:\n- protect-kernel-defaults=true\n- read-only-port=0\n- authorization-mode=Webhook" > /etc/rancher/rke2/config.yaml

  echo -e "apiVersion: audit.k8s.io/v1\nkind: Policy\nmetadata:\n  name: rke2-audit-policy\nrules:\n  - level: Metadata\n    resources:\n    - group: \"\"\n      resources: [\"secrets\"]\n  - level: RequestResponse\n    resources:\n    - group: \"\"\n      resources: [\"*\"]" > /etc/rancher/rke2/audit-policy.yaml
  echo -e "---\napiVersion: helm.cattle.io/v1\nkind: HelmChartConfig\nmetadata:\n  name: rke2-ingress-nginx\n  namespace: kube-system\nspec:\n  valuesContent: |-\n    controller:\n      config:\n        use-forwarded-headers: true\n      extraArgs:\n        enable-ssl-passthrough: true" > /var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml

  curl -sfL https://get.rke2.io | sh - > /dev/null 2>&1 || fatal "rke2 install didn't work"
  systemctl enable --now rke2-server.service > /dev/null 2>&1 || fatal "rke2-server didn't start"

  until systemctl is-active -q rke2-server; do 
    sleep 2
  done

  echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml PATH=$PATH:/usr/local/bin/:/var/lib/rancher/rke2/bin/" >> ~/.bashrc
  source ~/.bashrc

  until [ $(kubectl get node | grep Ready | wc -l) == 1 ]; do 
    sleep 2
  done
  
  info "RKE2 cluster is active!"

  info "Installing helm..."
  cd /opt/hauler

  curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash  > /dev/null 2>&1
  mv /usr/local/bin/helm /usr/bin/helm > /dev/null 2>&1
}

setupWorker() {
  info "Installing required packages zstd and createrepo..."
  mkdir /opt/hauler && yum install -y zstd > /dev/null 2>&1

  setupOS

  mkdir -p /etc/rancher/rke2/
  echo -e "server: https://$serverIp:9345\ntoken: ${BOOTSTRAP_PASSWORD}\nwrite-kubeconfig-mode: 0600\n#profile: cis-1.23\nkube-apiserver-arg:\n- \"authorization-mode=RBAC,Node\"\nkubelet-arg:\n- \"protect-kernel-defaults=true\" " > /etc/rancher/rke2/config.yaml
  
  curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh - > /dev/null 2>&1 || fatal "rke2 agent install didn't work"
  systemctl enable --now rke2-agent.service > /dev/null 2>&1 || fatal "rke2-agent didn't start"
  
  info "Worker node is added to the cluster!"
}

setupRegistry() {
  setupHauler

  warn "- Performing Hauler store sync - will take some time..."
  hauler store sync -f /opt/hauler/airgap_hauler.yaml || { fatal "hauler failed to sync - check airgap_hauler.yaml for errors" ; }
  echo -n "  - Hauler store synced"
  infoOK
    
  rsync -avP /usr/bin/hauler /opt/hauler/hauler > /dev/null 2>&1

  info "Starting hauler registry..."
  hauler store serve registry
}

rancher() {
  ssh -i ${SSH_KEY} ${USER}@${CP_SERVER_IP} "cat /etc/rancher/rke2/rke2.yaml" > /root/.kube/config
  sed -i "s|server: https://127.0.0.1:6443|server: https://${CP_SERVER_IP}:6443|" /root/.kube/config
  
  info "Deploying cert-manager..."
  helm upgrade -i cert-manager oci://${REGISTRY_IP}:5000/hauler/cert-manager --version "${CERT_VERSION}" --namespace cert-manager --create-namespace --set crds.enabled=true --plain-http

  info "Deploying rancher..."
  helm upgrade -i rancher oci://${REGISTRY_IP}:5000/hauler/rancher --namespace cattle-system --create-namespace --set bootstrapPassword=${BOOTSTRAP_PASSWORD} --set replicas=1 --set auditLog.level=2 --set auditLog.destination=hostPath --set useBundledSystemChart=true --set hostname=${FQDN} --plain-http

  info "Updating ingress..."
  kubectl patch ingress rancher -n cattle-system --type=json -p='[{"op": "add", "path": "/spec/rules/-", "value": {"host": '${INTERNAL_FQDN}',"http":{"paths":[{"backend":{"service":{"name":"rancher","port":{"number":80}}},"pathType":"ImplementationSpecific"}]}}}]'
  kubectl patch ingress rancher -n cattle-system --type=json -p='[{"op": "add", "path": "/spec/tls/0/hosts/-", "value": '${INTERNAL_FQDN}'}]'
  sleep 20
  kubectl patch setting server-url --type=json -p='[{"op": "add", "path": "/value", "value": 'https://${INTERNAL_FQDN}'}]'
}

info() { 
    echo -e "$GREEN[INFO]$NO_COLOR $1"
}

warn() { 
    echo -e "$YELLOW[WARN]$NO_COLOR $1"
}

fatal() { 
    echo -e "$RED[ERROR]$NO_COLOR $1"
    exit 1
}

infoOK() { 
    echo -e "$GREEN" "[OK]" "$NO_COLOR"
}

usage() {
	cat << EOF

$(basename "$0")

This script will deploy an air-gapped Rancher Server using Hauler on top of an RKE2 cluster. You will need the

following:

    * 5 RHEL VMs - 1 client node, 1 registry, 1 control plane nodes, 2 worker nodes
    * PEM file to ssh into the control plane and worker nodes
    * Run as root

USAGE: % ./$(basename "$0") [options]

OPTIONS:
	-h	-> Usage

EXAMPLES OF USAGE:

* Run script
	
	$ ./$(basename "$0")

* Run build setup on client node

    $ ./$(basename "$0") -b

* Run control plane node setup

    $ ./$(basename "$0") -c

* Run worker node setup

    $ ./$(basename "$0") -w

* Run registry
  
      $ ./$(basename "$0") -a

* Run Rancher setup

    $ ./$(basename "$0") -r

EOF
}

while getopts "hbcwr" opt; do
  case ${opt} in
    h)
      usage
      exit 0;;
    b)
      build
      exit 0;;
    c)
      setupControlPlane
      exit 0;;
    w)
      setupWorker
      exit 0;;
    a)
      setupRegistry
      exit 0;;
    r)
      rancher
      exit 0;;
    *)
      echo "Invalid option. Valid option(s) are [-h, -b, -c, -w, -r]." 2>&1
      exit 1;;
  esac
done

Main() {
    echo -e "\x1B[96m======================================================"
    echo -e "\tSetup Air-gapped Rancher using Hauler"
    echo -e "======================================================"
    echo -e "This script will deploy an air-gapped Rancher using Hauler."
    echo -e "-------------------------------------------------------------\x1B[0m"

    usage
}

Main "$@"