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

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "machine_config_name" {
  type        = string
  description = "Machine config name"
}

variable "ami" {
  type        = string
  description = "AMI"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "security_group" {
  type        = string
  description = "Security group"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "zone" {
  type        = string
  description = "Zone"
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