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
# CLOUD CREDENTIALS
########################
resource "rancher2_cloud_credential" "cloud_credential" {
  name = var.cloud_credential_name
  google_credential_config {
    auth_encoded_json = file(var.google_credential_file_path)
  }
}

########################
# GKE CLUSTER
########################
resource "rancher2_cluster" "cluster" {
  name = var.cluster_name
  gke_config_v2 {
    name                     = var.cluster_name
    google_credential_secret = rancher2_cloud_credential.cloud_credential.id
    region                   = var.region
    project_id               = var.project_id
    kubernetes_version       = var.kubernetes_version
    network                  = var.network
    subnetwork               = var.subnetwork
    node_pools {
      initial_node_count  = var.initial_node_count
      max_pods_constraint = var.max_pods_constraint
      name                = var.node_pool_name
      version             = var.node_pool_version
    }
  }
}