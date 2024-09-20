variable "rancher_api_url" {
  type        = string
  description = "Rancher URL"
}

variable "rancher_admin_bearer_token" {
  type        = string
  description = "Admin bearer token"
}

variable "username" {
  type        = string
  description = "Username"
}

variable "password" {
  type        = string
  description = "Password"
}

variable "global_role_id" {
  type        = string
  description = "Global role ID"
}

variable "vsphere_boot2docker_url" {
  type        = string
  description = "Boot2docker URL"
}

variable "vsphere_cfgparam" {
  type        = string
  description = "Cfgparam"
}

variable "vsphere_clone_from" {
  type        = string
  description = "Clone from"
}

variable "vsphere_cloud_config" {
  type        = string
  description = "Cloud config"
}

variable "vsphere_cloudinit" {
  type        = string
  description = "Cloudinit"
}

variable "vsphere_content_library" {
  type        = string
  description = "Content library"
}

variable "vsphere_cpu_count" {
  type        = number
  description = "CPU count"
}

variable "vsphere_datacenter" {
  type        = string
  description = "Datacenter"
}

variable "vsphere_datastore" {
  type        = string
  description = "Datastore"
}

variable "vsphere_datastore_cluster" {
  type        = string
  description = "Datastore cluster"
}

variable "vsphere_disk_size" {
  type        = number
  description = "Disk size"
}

variable "vsphere_folder" {
  type        = string
  description = "Folder"
}

variable "vsphere_hostsystem" {
  type        = string
  description = "Hostsystem"
}

variable "vsphere_memory_size" {
  type        = number
  description = "Memory size"
}

variable "vsphere_network" {
  type        = string
  description = "Network"
}

variable "vsphere_password" {
  type        = string
  description = "Password"
}

variable "vsphere_pool" {
  type        = string
  description = "Pool"
}

variable "vsphere_ssh_password" {
  type        = string
  description = "SSH password"
}

variable "vsphere_ssh_port" {
  type        = number
  description = "SSH port"
}

variable "vsphere_ssh_user" {
  type        = string
  description = "SSH user"
}

variable "vsphere_ssh_user_group" {
  type        = string
  description = "SSH user group"
}

variable "vsphere_username" {
  type        = string
  description = "Username"
}

variable "vsphere_vcenter" {
  type        = string
  description = "vCenter"
}

variable "vsphere_vcenter_port" {
  type        = number
  description = "Port"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "network_plugin" {
  type        = string
  description = "Network plugin"
}

variable "node_template_name" {
  type        = string
  description = "Node template name"
}

variable "etcd_node_pool_name" {
  type        = string
  description = "Etcd node pool name"
}

variable "etcd_node_pool_quantity" {
  type        = number
  description = "Etcd node pool quantity"
}

variable "control_plane_node_pool_name" {
  type        = string
  description = "Control plane node pool name"
}

variable "control_plane_node_pool_quantity" {
  type        = number
  description = "Control plane node pool quantity"
}

variable "worker_node_pool_name" {
  type        = string
  description = "Worker node pool name"
}

variable "worker_node_pool_quantity" {
  type        = number
  description = "Worker node pool quantity"
}

variable "etcd_node_hostname_prefix" {
  type        = string
  description = "Etcd node hostname prefix"
}

variable "control_plane_node_hostname_prefix" {
  type        = string
  description = "Control plane node hostname prefix"
}

variable "worker_node_hostname_prefix" {
  type        = string
  description = "Worker node hostname prefix"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "default_pod_security_admission_configuration_template_name" {
  type        = string
  description = "Default pod security admission configuration template name"
}