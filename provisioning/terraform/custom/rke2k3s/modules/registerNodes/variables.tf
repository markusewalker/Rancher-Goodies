variable "aws_region" {
  type        = string
  description = "Defines the AWS region to be used"
}

variable "aws_access_key" {
  type        = string
  description = "Defines the AWS access key to be used"
}

variable "aws_secret_key" {
  type        = string
  description = "Defines the AWS secret key to be used"
}

variable "aws_ami" {
  type        = string
  description = "Defines the AWS AMI to be used"
}

variable "aws_instance_count" {
  type        = number
  description = "Defines the AWS instance count to be used"
  default     = 3
}

variable "aws_instance_type" {
  type        = string
  description = "Defines the AWS instance type to be used"
}

variable "aws_subnet" {
  type        = string
  description = "Defines the AWS subnet to be used"
}

variable "aws_security_group" {
  type        = string
  description = "Defines the AWS security group to be used"
}

variable "aws_volume_size" {
  type        = number
  description = "Defines the AWS instance size to be used"
}

variable "aws_prefix" {
  type        = string
  description = "Defines the AWS etcd prefix to be used"
  default     = ""
}

variable "aws_user" {
  type        = string
  description = "Defines the AWS user to be used"
}

variable "ssh_connection_type" {
  type        = string
  description = "Defines the SSH connection type to be used"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Defines the SSH private key path to be used"
}

variable "ssh_timeout" {
  type        = string
  description = "Defines the SSH timeout to be used"
}

variable "registration_command" {
  type        = string
  description = "Defines the registration command to be used"
}