terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.2.0"
    }
  }
}

provider "rancher2" {
  api_url   = var.rancher_api_url
  token_key = var.rancher_admin_bearer_token
  insecure  = true
}

########################
# MACHINE CONFIG
########################
resource "rancher2_machine_config_v2" "machine_config" {
  generate_name = var.machine_config_name
  amazonec2_config {
    ami            = var.ami
    region         = var.region
    security_group = [var.security_group]
    subnet_id      = var.subnet_id
    vpc_id         = var.vpc_id
    zone           = var.zone
  }
}

########################
# CREATE CLUSTER
########################
resource "rancher2_cluster" "cluster" {
  name                                                       = var.cluster_name
  default_pod_security_admission_configuration_template_name = var.default_pod_security_admission_configuration_template_name
  rke_config {
    kubernetes_version = var.kubernetes_version
    network {
      plugin = var.network_plugin
    }
  }
}