variable "rancher_api_url" {
  type        = string
  description = "Rancher URL"
}

variable "rancher_admin_bearer_token" {
  type        = string
  description = "Admin bearer token"
}

variable "client_id" {
  type        = string
  description = "Client ID"
}

variable "client_secret" {
  type        = string
  description = "Client secret"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID"
}

variable "cloud_credential_name" {
  type        = string
  description = "Cloud credential name"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "resource_group" {
  type        = string
  description = "Resource group"
}

variable "resource_location" {
  type        = string
  description = "Resource location"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "network_plugin" {
  type        = string
  description = "Network plugin"
}

variable "virtual_network" {
  type        = string
  description = "Virtual network"
}

variable "subnet" {
  type        = string
  description = "Subnet"
}

variable "network_dns_service_ip" {
  type        = string
  description = "DNS service IP"
}

variable "network_docker_bridge_cidr" {
  type        = string
  description = "Docker bridge CIDR"
}

variable "network_service_cidr" {
  type        = string
  description = "Service CIDR"
}

variable "availability_zones" {
  type        = string
  description = "Availability zones"
}

variable "node_pool_name" {
  type        = string
  description = "Node pool name"
}

variable "node_pool_mode" {
  type        = string
  description = "Node pool mode"
}

variable "node_count" {
  type        = number
  description = "Node count"
}

variable "orchestrator_version" {
  type        = string
  description = "Orchestrator version"
}

variable "os_disk_size_gb" {
  type        = number
  description = "OS disk size in GB"
}

variable "vm_size" {
  type        = string
  description = "VM size"
}

variable "taints" {
  type        = string
  description = "Taints"
}