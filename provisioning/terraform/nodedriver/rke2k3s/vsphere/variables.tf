variable "rancher_api_url" {
  type        = string
  description = "Rancher API URL"
}

variable "rancher_admin_bearer_token" {
  type        = string
  description = "Admin token"
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
  description = "vCenter port"
}

variable "machine_config_name" {
  type        = string
  description = "Machine config name"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "default_cluster_role_for_project_members" {
  type        = string
  description = "Default cluster role for project members"
}

variable "default_pod_security_admission_configuration_template_name" {
  type        = string
  description = "Default pod security admission configuration template name"
}

variable "machine_pool_etcd_name" {
  type        = string
  description = "Etcd pool name"
}

variable "machine_pool_control_plane_name" {
  type        = string
  description = "Control plane pool name"
}

variable "machine_pool_worker_name" {
  type        = string
  description = "Worker pool name"
}

variable "machine_pool_etcd_quantity" {
  type        = number
  description = "Etcd pool quantity"
}

variable "machine_pool_control_plane_quantity" {
  type        = number
  description = "Control plane pool quantity"
}

variable "machine_pool_worker_quantity" {
  type        = number
  description = "Worker pool quantity"
}


variable "cloud_credential_name" {
  type        = string
  description = "Cloud credential name"
}