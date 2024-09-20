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

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant ID"
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