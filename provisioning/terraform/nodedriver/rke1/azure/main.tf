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

resource "rancher2_node_template" "node_template" {
  name = var.node_template_name
  azure_config {
    availability_set    = var.azure_availability_set
    client_id           = var.azure_client_id
    client_secret       = var.azure_client_secret
    subscription_id     = var.azure_subscription_id
    environment         = var.azure_environment
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

resource "rancher2_node_pool" "etcd_node_pool" {
  cluster_id       = rancher2_cluster.cluster.id
  name             = var.etcd_node_pool_name
  hostname_prefix  = var.etcd_node_hostname_prefix
  node_template_id = rancher2_node_template.node_template.id
  quantity         = var.etcd_node_pool_quantity
  control_plane    = false
  etcd             = true
  worker           = false
}

resource "rancher2_node_pool" "control_plane_node_pool" {
  cluster_id       = rancher2_cluster.cluster.id
  name             = var.control_plane_node_pool_name
  hostname_prefix  = var.control_plane_node_hostname_prefix
  node_template_id = rancher2_node_template.node_template.id
  quantity         = var.control_plane_node_pool_quantity
  control_plane    = true
  etcd             = false
  worker           = false
}

resource "rancher2_node_pool" "worker_node_pool" {
  cluster_id       = rancher2_cluster.cluster.id
  name             = var.worker_node_pool_name
  hostname_prefix  = var.worker_node_hostname_prefix
  node_template_id = rancher2_node_template.node_template.id
  quantity         = var.worker_node_pool_quantity
  control_plane    = false
  etcd             = false
  worker           = true
}