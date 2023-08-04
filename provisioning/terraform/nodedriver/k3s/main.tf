terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "latest"
    }
  }
}

provider "rancher2" {
  api_url   = var.rancher_api_url
  token_key = var.rancher_admin_bearer_token
  insecure  = true
}

########################
# CLOUD CREDENTIALS
########################
resource "rancher2_cloud_credential" "cloud_credential" {
  name = var.cloud_credential_name
  amazonec2_credential_config {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
  }
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
resource "rancher2_cluster_v2" "cluster" {
  name                                     = var.cluster_name
  kubernetes_version                       = var.kubernetes_version
  enable_network_policy                    = false
  default_cluster_role_for_project_members = var.default_cluster_role_for_project_members
  rke_config {
    machine_pools {
      name                         = var.machine_pool_etcd_name
      cloud_credential_secret_name = rancher2_cloud_credential.cloud_credential.id
      control_plane_role           = false
      etcd_role                    = true
      worker_role                  = false
      quantity                     = var.machine_pool_etcd_quantity
      machine_config {
        kind = rancher2_machine_config_v2.machine_config.kind
        name = rancher2_machine_config_v2.machine_config.name
      }
    }
    machine_pools {
      name                         = var.machine_pool_control_plane_name
      cloud_credential_secret_name = rancher2_cloud_credential.cloud_credential.id
      control_plane_role           = true
      etcd_role                    = false
      worker_role                  = false
      quantity                     = var.machine_pool_control_plane_quantity
      machine_config {
        kind = rancher2_machine_config_v2.machine_config.kind
        name = rancher2_machine_config_v2.machine_config.name
      }
    }
    machine_pools {
      name                         = var.machine_pool_worker_name
      cloud_credential_secret_name = rancher2_cloud_credential.cloud_credential.id
      control_plane_role           = false
      etcd_role                    = false
      worker_role                  = true
      quantity                     = var.machine_pool_worker_quantity
      machine_config {
        kind = rancher2_machine_config_v2.machine_config.kind
        name = rancher2_machine_config_v2.machine_config.name
      }
    }
  }
}