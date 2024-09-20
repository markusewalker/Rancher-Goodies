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

variable "azure_availability_set" {
  type        = string
  description = "Azure availability set"
}

variable "azure_client_id" {
  type        = string
  description = "Azure client ID"
}

variable "azure_client_secret" {
  type        = string
  description = "Azure client secret"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_environment" {
  type        = string
  description = "Azure environment"
}

variable "azure_custom_data" {
  type        = string
  description = "Azure custom data"
}

variable "azure_disk_size" {
  type        = number
  description = "Azure disk size"
}

variable "azure_fault_domain_count" {
  type        = number
  description = "Azure fault domain count"
}

variable "azure_image" {
  type        = string
  description = "Azure image"
}

variable "azure_location" {
  type        = string
  description = "Azure location"
}

variable "azure_open_ports" {
  type        = list(string)
  description = "Azure open ports"
}

variable "azure_private_ip_address" {
  type        = string
  description = "Azure private IP address"
}

variable "azure_resource_group" {
  type        = string
  description = "Azure resource group"
}

variable "azure_size" {
  type        = string
  description = "Azure size"
}

variable "azure_ssh_user" {
  type        = string
  description = "Azure SSH user"
}

variable "azure_storage_type" {
  type        = string
  description = "Azure storage type"
}

variable "azure_update_domain_count" {
  type        = number
  description = "Azure update domain count"
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