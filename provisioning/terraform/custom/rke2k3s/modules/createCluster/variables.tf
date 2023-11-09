variable "rancher_api_url" {
  type        = string
  description = "Rancher URL"
}

variable "rancher_admin_bearer_token" {
  type        = string
  description = "Admin token"
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