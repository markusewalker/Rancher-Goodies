#!/usr/bin/bash

# Authored By: Markus Walker
# Date Modified: 12/21/22

setupRKE() {
    echo -e "Downloading RKE CLI..."
    wget https://github.com/rancher/rke/releases/download/${VERSION}/rke_${OS}-${ARCH}

    echo -e "\nRenaming RKE CLI..."
    mv rke_${OS}-${ARCH} rke
    chmod +x rke

    echo -e "\nMoving RKE CLI to /usr/local/bin..."
    sudo mv rke /usr/local/bin

    echo -e "\nVerifying Rancher RKE is setup..."
    rke
}

setupKubelet() {
    echo -e "\nInstalling kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
}

runRKE() {
    echo -e "\nCreating cluster.yml file..."
    cat << EOF >> cluster.yml
kubernetes_version: ${KUBERNETES_VERSION}
nodes:
  - address: ${NODE1_PUBLIC}
    port: ${PORT}
    internal_address: ${NODE1_PRIVATE}
    ssh_key_path: ${SSH_PATH_NODE1}
    user: ${USER}
    role: [etcd, controlplane,worker]
  - address: ${NODE2_PUBLIC}
    port: ${PORT}
    internal_address: ${NODE2_PRIVATE}
    ssh_key_path: ${SSH_PATH_NODE2}
    user: ${USER}
    role: [etcd, controlplane,worker]
  - address: ${NODE3_PUBLIC}
    port: ${PORT}
    internal_address: ${NODE3_PRIVATE}
    ssh_key_path: ${SSH_PATH_NODE3}
    user: ${USER}
    role: [etcd, controlplane,worker]
services:
  etcd:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
    external_urls: []
    ca_cert: ""
    cert: ""
    key: ""
    path: ""
    uid: 52034
    gid: 52034
    snapshot: true
    retention: ""
    creation: ""
    backup_config: null
  kube-api:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
    service_cluster_ip_range: ""
    service_node_port_range: ""
    pod_security_policy: false
    always_pull_images: false
    secrets_encryption_config:
      enabled: true
      custom_config: null
    audit_log:
      enabled: true
      configuration: null
    admission_configuration:
       apiVersion: apiserver.config.k8s.io/v1
       kind: AdmissionConfiguration
       plugins:
         - name: PodSecurity
           configuration:
             apiVersion: pod-security.admission.config.k8s.io/v1
             kind: PodSecurityConfiguration
             defaults:
               enforce: restricted
               enforce-version: latest
             exemptions:
               namespaces: 
               - ingress-nginx
               - kube-system
               - cattle-system
               - cattle-epinio-system
               - cattle-fleet-system
               - longhorn-system
               - cattle-neuvector-system
               - cattle-monitoring-system
               - rancher-alerting-drivers
               - cis-operator-system
               - cattle-csp-adapter-system
               - cattle-externalip-system
               - cattle-gatekeeper-system
               - istio-system
               - cattle-istio-system
               - cattle-logging-system
               - cattle-windows-gmsa-system
               - cattle-sriov-system
               - cattle-ui-plugin-system
               - tigera-operator
               runtimeClasses: []
               usernames: []
    event_rate_limit:
      enabled: true
      #configuration: null
  kube-controller:
    image: ""
    extra_args:
      feature-gates: RotateKubeletServerCertificate=true
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
    cluster_cidr: ""
    service_cluster_ip_range: ""
  scheduler:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
  kubelet:
    image: ""
    extra_args:
      feature-gates: RotateKubeletServerCertificate=true
      protect-kernel-defaults: "true"
      tls-cipher-suites: TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
    cluster_domain: cluster.local
    infra_container_image: ""
    cluster_dns_server: ""
    fail_swap_on: false
    generate_serving_certificate: true
  kubeproxy:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
network:
  plugin: ""
  options: {}
  mtu: 0
  node_selector: {}
  update_strategy: null
authentication:
  strategy: ""
  sans: []
  webhook: null
addons: |
  apiVersion: policy/v1beta1
  kind: PodSecurityPolicy
  metadata:
    name: restricted
  spec:
    requiredDropCapabilities:
    - NET_RAW
    privileged: false
    allowPrivilegeEscalation: false
    defaultAllowPrivilegeEscalation: false
    fsGroup:
      rule: RunAsAny
    runAsUser:
      rule: MustRunAsNonRoot
    seLinux:
      rule: RunAsAny
    supplementalGroups:
      rule: RunAsAny
    volumes:
    - emptyDir
    - secret
    - persistentVolumeClaim
    - downwardAPI
    - configMap
    - projected
  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: psp:restricted
  rules:
  - apiGroups:
    - extensions
    resourceNames:
    - restricted
    resources:
    - podsecuritypolicies
    verbs:
    - use
  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: psp:restricted
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: psp:restricted
  subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: system:serviceaccounts
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: system:authenticated
  ---
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: default-allow-all
  spec:
    podSelector: {}
    ingress:
    - {}
    egress:
    - {}
    policyTypes:
    - Ingress
    - Egress
  ---
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: default
  automountServiceAccountToken: false
addons_include: []
system_images:
  etcd: ""
  alpine: ""
  nginx_proxy: ""
  cert_downloader: ""
  kubernetes_services_sidecar: ""
  kubedns: ""
  dnsmasq: ""
  kubedns_sidecar: ""
  kubedns_autoscaler: ""
  coredns: ""
  coredns_autoscaler: ""
  nodelocal: ""
  kubernetes: ""
  flannel: ""
  flannel_cni: ""
  calico_node: ""
  calico_cni: ""
  calico_controllers: ""
  calico_ctl: ""
  calico_flexvol: ""
  canal_node: ""
  canal_cni: ""
  canal_controllers: ""
  canal_flannel: ""
  canal_flexvol: ""
  weave_node: ""
  weave_cni: ""
  pod_infra_container: ""
  ingress: ""
  ingress_backend: ""
  metrics_server: ""
  windows_pod_infra_container: ""
authorization:
  mode: ""
  options: {}
ignore_docker_version: false
private_registries: []
ingress:
  provider: ""
  options: {}
  node_selector: {}
  extra_args: {}
  dns_policy: ""
  extra_envs: []
  extra_volumes: []
  extra_volume_mounts: []
  update_strategy: null
  http_port: 0
  https_port: 0
  network_mode: ""
cluster_name:
cloud_provider:
  name: ""
prefix_path: ""
win_prefix_path: ""
addon_job_timeout: 0
bastion_host:
  address: ""
  port: ""
  user: ""
  ssh_key: ""
  ssh_key_path: ""
  ssh_cert: ""
  ssh_cert_path: ""
monitoring:
  provider: ""
  options: {}
  node_selector: {}
  update_strategy: null
  replicas: null
restore:
  restore: false
  snapshot_name: ""
dns: null
upgrade_strategy:
  max_unavailable_worker: ""
  max_unavailable_controlplane: ""
  drain: null
  node_drain_input: null
EOF

    rke up --config cluster.yml

    echo -e "\nCopying over kubeconfig file to home directory..."
    cp kube_config_cluster.yml $HOME/.kube/config

    echo -e "\nVerifying that the cluster is up and running..."
    kubectl get nodes
}

usage() {
	cat << EOF

$(basename "$0")

Setup an RKE1 cluster with 3 nodes. This script assumes you have the following installed on each of the targeted machines:

    - Docker
    - SSH

You will need to provide the following information before running the script:

    - SSH Key Path for each node
    - Kubernetes Version
    - Node1 Public/Private IP Address
    - Node2 Public/Private IP Address
    - Node3 Public/Private IP Address
    - User for each node (should be the same)

USAGE: % ./$(basename "$0") [options]

OPTIONS:
	-h		-> Usage

EXAMPLES:

* Run script interactively

	% ./$(basename "$0")

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
	echo -e "\x1B[96m=========================================="
	echo -e "\tRKE1 Hardened Cluster Setup w/PSA"
	echo -e "==========================================\x1B[0m\n"

  export OS=`uname -s | awk '{print tolower($0)}'`
  export VERSION=""
  export ARCH=""
  export USER=""
  export PORT=22
  export NODE1_PUBLIC=""
  export NODE1_PRIVATE=""
  export NODE2_PUBLIC=""
  export NODE2_PRIVATE=""
  export NODE3_PUBLIC=""
  export NODE3_PRIVATE=""
  export SSH_PATH_NODE1="/net/$NODE1_PUBLIC/$HOME/.ssh/id_rsa"
  export SSH_PATH_NODE2="/net/$NODE2_PUBLIC/$HOME/.ssh/id_rsa"
  export SSH_PATH_NODE3="/net/$NODE3_PUBLIC/$HOME/.ssh/id_rsa"
  export KUBERNETES_VERSION=""
    
  setupRKE
  setupKubelet
  runRKE
}

Main "$@"