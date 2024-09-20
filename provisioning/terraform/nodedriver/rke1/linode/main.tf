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
  linode_config {
    token     = var.linode_token
    image     = var.linode_image
    region    = var.linode_region
    root_pass = var.linode_root_password
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