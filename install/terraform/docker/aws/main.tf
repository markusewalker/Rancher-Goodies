terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.53.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "aws_instance" {
  ami                    = var.aws_ami
  instance_type          = var.aws_instance_type
  subnet_id              = var.aws_subnet
  vpc_security_group_ids = [var.aws_security_group]

  root_block_device {
    volume_size = var.aws_volume_size
  }

  tags = {
    Name = var.aws_prefix
  }

  connection {
    type        = var.ssh_connection_type
    host        = aws_instance.aws_instance.public_ip
    user        = var.aws_user
    private_key = file(var.ssh_private_key_path)
    timeout     = var.ssh_timeout
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d --privileged --restart=unless-stopped -p 80:80 -p 443:443 -e CATTLE_BOOTSTRAP_PASSWORD=${var.rancher_password} rancher/rancher:${var.rancher_tag_version}"
    ]
  }
}