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

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "aws_ami" {
  type        = string
  description = "AWS AMI"
}

variable "aws_instance_type" {
  type        = string
  description = "AWS instance type"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_security_group_name" {
  type        = string
  description = "AWS security group name"
}

variable "aws_subnet_id" {
  type        = string
  description = "AWS subnet ID"
}

variable "aws_vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "aws_zone" {
  type        = string
  description = "AWS zone"
}

variable "aws_root_size" {
  type        = number
  description = "AWS root size"
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

variable "node_hostname_prefix" {
  type        = string
  description = "Node hostname prefix"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "default_pod_security_admission_configuration_template_name" {
  type        = string
  description = "Default pod security admission configuration template name"
}