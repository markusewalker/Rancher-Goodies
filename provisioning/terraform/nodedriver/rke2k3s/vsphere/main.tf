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
  vsphere_credential_config {
    password     = var.vsphere_password
    username     = var.vsphere_username
    vcenter      = var.vsphere_vcenter
    vcenter_port = var.vsphere_vcenter_port
  }
}

resource "rancher2_machine_config_v2" "machine_config" {
  generate_name = var.machine_config_name
  vsphere_config {
    boot2docker_url   = var.vsphere_boot2docker_url
    cfgparam          = [var.vsphere_cfgparam]
    clone_from        = var.vsphere_clone_from
    cloud_config      = var.vsphere_cloud_config
    cloudinit         = var.vsphere_cloudinit
    content_library   = var.vsphere_content_library
    cpu_count         = var.vsphere_cpu_count
    datacenter        = var.vsphere_datacenter
    datastore         = var.vsphere_datastore
    datastore_cluster = var.vsphere_datastore_cluster
    disk_size         = var.vsphere_disk_size
    folder            = var.vsphere_folder
    hostsystem        = var.vsphere_hostsystem
    memory_size       = var.vsphere_memory_size
    network           = [var.vsphere_network]
    pool              = var.vsphere_pool
    ssh_password      = var.vsphere_ssh_password
    ssh_port          = var.vsphere_ssh_port
    ssh_user          = var.vsphere_ssh_user
    ssh_user_group    = var.vsphere_ssh_user_group
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