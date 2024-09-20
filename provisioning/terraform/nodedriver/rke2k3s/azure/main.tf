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

resource "rancher2_user" "user" {
  name     = var.username
  username = var.username
  password = var.password
  enabled  = true
}

resource "rancher2_global_role_binding" "global_role_binding" {
  name           = var.username
  global_role_id = var.global_role_id
  user_id        = rancher2_user.user.id
}

resource "rancher2_cloud_credential" "cloud_credential" {
  name = var.cloud_credential_name
  azure_credential_config {
    client_id       = var.azure_client_id
    client_secret   = var.azure_client_secret
    subscription_id = var.azure_subscription_id
    environment     = var.azure_environment
    tenant_id       = var.azure_tenant_id
  }
}

resource "rancher2_machine_config_v2" "machine_config" {
  generate_name = var.machine_config_name
  azure_config {
    availability_set    = var.azure_availability_set
    custom_data         = var.azure_custom_data
    disk_size           = var.azure_disk_size
    fault_domain_count  = var.azure_fault_domain_count
    image               = var.azure_image
    location            = var.azure_location
    managed_disks       = false
    no_public_ip        = false
    open_port           = var.azure_open_ports
    private_ip_address  = var.azure_private_ip_address
    resource_group      = var.azure_resource_group
    size                = var.azure_size
    ssh_user            = var.azure_ssh_user
    static_public_ip    = false
    storage_type        = var.azure_storage_type
    update_domain_count = var.azure_update_domain_count
    use_private_ip      = false
  }
}

resource "rancher2_cluster_v2" "cluster" {
  name                                                       = var.cluster_name
  kubernetes_version                                         = var.kubernetes_version
  enable_network_policy                                      = false
  default_cluster_role_for_project_members                   = var.default_cluster_role_for_project_members
  default_pod_security_admission_configuration_template_name = var.default_pod_security_admission_configuration_template_name
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