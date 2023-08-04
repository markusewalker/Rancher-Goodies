variable "aws_ami" {
  type        = string
  description = "Defines the AWS AMI"
}

variable "aws_access_key" {
  type        = string
  description = "Defines the AWS access key"
}

variable "aws_instance_type" {
  type        = string
  description = "Defines the AWS instance type"
}

variable "aws_prefix" {
  type        = string
  description = "Defines the AWS prefix"
}

variable "aws_region" {
  type        = string
  description = "Defines the AWS region"
}

variable "aws_secret_key" {
  type        = string
  description = "Defines the AWS secret key"
}

variable "aws_security_group" {
  type        = string
  description = "Defines the AWS security group"
}

variable "aws_subnet" {
  type        = string
  description = "Defines the AWS subnet"
}

variable "aws_user" {
  type        = string
  description = "Defines the AWS user"
}

variable "aws_volume_size" {
  type        = number
  description = "Defines the AWS volume size"
}

variable "rancher_password" {
  type        = string
  description = "Defines the Rancher password"
}

variable "rancher_tag_version" {
  type        = string
  description = "Defines the Rancher tag version"
}

variable "ssh_connection_type" {
  type        = string
  description = "Defines the SSH connection type"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Defines the SSH private key path"
}

variable "ssh_timeout" {
  type        = string
  description = "Defines the SSH timeout"
}