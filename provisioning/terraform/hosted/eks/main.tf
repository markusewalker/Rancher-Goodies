terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "5.0.0"
    }
  }
}

provider "rancher2" {
  api_url   = var.rancher_api_url
  token_key = var.rancher_admin_bearer_token
  insecure  = true
}

resource "rancher2_cloud_credential" "cloud_credential" {
  name = var.cloud_credential_name
  amazonec2_credential_config {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
  }
}

resource "rancher2_cluster" "cluster" {
  name = var.cluster_name
  eks_config_v2 {
    cloud_credential_id = rancher2_cloud_credential.cloud_credential.id
    region              = var.aws_region
    kubernetes_version  = var.kubernetes_version
    node_groups {
      name          = var.aws_node_group_name
      instance_type = var.aws_instance_type
      desired_size  = var.aws_desired_size
      max_size      = var.aws_max_size
      node_role     = var.aws_node_role
    }
    private_access = true
    public_access  = false
  }
}