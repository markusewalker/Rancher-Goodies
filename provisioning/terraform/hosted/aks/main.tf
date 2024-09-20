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
  azure_credential_config {
    client_id       = var.client_id
    client_secret   = var.client_secret
    subscription_id = var.subscription_id
  }
}

resource "rancher2_cluster" "cluster" {
  name = var.cluster_name
  aks_config_v2 {
    cloud_credential_id        = rancher2_cloud_credential.cloud_credential.id
    resource_group             = var.resource_group
    resource_location          = var.resource_location
    dns_prefix                 = var.dns_prefix
    kubernetes_version         = var.kubernetes_version
    network_plugin             = var.network_plugin
    virtual_network            = var.virtual_network
    subnet                     = var.subnet
    network_dns_service_ip     = var.network_dns_service_ip
    network_docker_bridge_cidr = var.network_docker_bridge_cidr
    network_service_cidr       = var.network_service_cidr
    node_pools {
      availability_zones   = [var.availability_zones]
      name                 = var.node_pool_name
      mode                 = var.node_pool_mode
      count                = var.node_count
      orchestrator_version = var.orchestrator_version
      os_disk_size_gb      = var.os_disk_size_gb
      vm_size              = var.vm_size
      taints               = [var.taints]
    }
  }
}