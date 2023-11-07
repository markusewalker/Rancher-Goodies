variable "rancher_api_url" {
  type        = string
  description = "Rancher URL"
}

variable "rancher_admin_bearer_token" {
  type        = string
  description = "Admin bearer token"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_desired_size" {
  type        = number
  description = "AWS desired size"
}

variable "aws_instance_type" {
  type        = string
  description = "AWS instance type"
}

variable "aws_max_size" {
  type        = number
  description = "AWS max size"
}

variable "aws_node_group_name" {
  type        = string
  description = "AWS node group name"
}

variable "aws_node_role" {
  type        = string
  description = "AWS node role"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "cloud_credential_name" {
  type        = string
  description = "Cloud credential name"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}