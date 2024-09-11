terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.23.1"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

resource "linode_instance" "linode_instance" {
  label     = var.linode_label
  image     = var.linode_image
  region    = var.linode_region
  type      = var.linode_type
  root_pass = var.linode_root_pass

  tags       = [var.linode_tags]
  swap_size  = 256
  private_ip = true

  connection {
    type     = var.ssh_connection_type
    host     = self.ip_address
    user     = var.linode_user
    password = var.linode_root_pass
    timeout  = var.ssh_timeout
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://releases.rancher.com/install-docker/24.0.sh | sh; docker run -d --privileged --restart=unless-stopped -p 80:80 -p 443:443 -e CATTLE_BOOTSTRAP_PASSWORD=${var.rancher_password} rancher/rancher:${var.rancher_tag_version}"
    ]
  }
}