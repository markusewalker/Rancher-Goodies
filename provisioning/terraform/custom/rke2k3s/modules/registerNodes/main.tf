terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

module "etcd-node" {
  source               = "./modules"
  aws_region           = var.aws_region
  aws_access_key       = var.aws_access_key
  aws_secret_key       = var.aws_secret_key
  aws_ami              = var.aws_ami
  aws_instance_count   = 3
  aws_prefix           = "tf-custom-etcd"
  aws_instance_type    = var.aws_instance_type
  aws_subnet           = var.aws_subnet
  aws_security_group   = var.aws_security_group
  aws_volume_size      = var.aws_volume_size
  ssh_connection_type  = var.ssh_connection_type
  aws_user             = var.aws_user
  ssh_private_key_path = var.ssh_private_key_path
  ssh_timeout          = var.ssh_timeout
  registration_command = "${var.registration_command} --etcd"
}

module "control-plane-node" {
  source               = "./modules"
  aws_region           = var.aws_region
  aws_access_key       = var.aws_access_key
  aws_secret_key       = var.aws_secret_key
  aws_ami              = var.aws_ami
  aws_instance_count   = 2
  aws_prefix           = "tf-custom-control-plane"
  aws_instance_type    = var.aws_instance_type
  aws_subnet           = var.aws_subnet
  aws_security_group   = var.aws_security_group
  aws_volume_size      = var.aws_volume_size
  ssh_connection_type  = var.ssh_connection_type
  aws_user             = var.aws_user
  ssh_private_key_path = var.ssh_private_key_path
  ssh_timeout          = var.ssh_timeout
  registration_command = "${var.registration_command} --controlplane"
}

module "worker-node" {
  source               = "./modules"
  aws_region           = var.aws_region
  aws_access_key       = var.aws_access_key
  aws_secret_key       = var.aws_secret_key
  aws_ami              = var.aws_ami
  aws_instance_count   = 3
  aws_prefix           = "tf-custom-worker"
  aws_instance_type    = var.aws_instance_type
  aws_subnet           = var.aws_subnet
  aws_security_group   = var.aws_security_group
  aws_volume_size      = var.aws_volume_size
  ssh_connection_type  = var.ssh_connection_type
  aws_user             = var.aws_user
  ssh_private_key_path = var.ssh_private_key_path
  ssh_timeout          = var.ssh_timeout
  registration_command = "${var.registration_command} --worker"
}