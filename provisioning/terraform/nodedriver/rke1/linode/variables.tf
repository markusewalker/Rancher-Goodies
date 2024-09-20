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

variable "linode_token" {
  type        = string
  description = "Linode token"
}

variable "linode_image" {
  type        = string
  description = "Image"
}

variable "linode_region" {
  type        = string
  description = "Region"
}

variable "linode_root_password" {
  type        = string
  description = "Root password"
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