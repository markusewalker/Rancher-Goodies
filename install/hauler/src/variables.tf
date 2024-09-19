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

variable "aws_instance_size" {
  type        = number
  description = "Defines the AWS instance size to be used"
}

variable "aws_registry_size" {
  type        = number
  description = "Defines the AWS registry size to be used"
}

variable "aws_prefix" {
  type        = string
  description = "Defines the AWS prefix to be used"
}

variable "aws_server_prefix" {
  type        = string
  description = "Defines the AWS server prefix to be used"
}

variable "aws_agent1_prefix" {
  type        = string
  description = "Defines the AWS agent1 prefix to be used"
}

variable "aws_agent2_prefix" {
  type        = string
  description = "Defines the AWS agent2 prefix to be used"
}

variable "aws_registry_prefix" {
  type        = string
  description = "Defines the AWS registry prefix to be used"
}

variable "aws_client_prefix" {
  type        = string
  description = "Defines the AWS client prefix to be used"
}

variable "aws_user" {
  type        = string
  description = "Defines the AWS user to be used"
}

variable "aws_vpc" {
  type        = string
  description = "Defines the AWS VPC to be used"
}

variable "aws_route53_zone" {
  type        = string
  description = "Defines the AWS Route53 zone to be used"
}

variable "key_name" {
  type        = string
  description = "Defines the key name to be used"
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