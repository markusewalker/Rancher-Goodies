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
# CREATE RKE1 CLUSTER
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

########################
# CREATE NODE TEMPLATE
########################
resource "rancher2_node_template" "node_template" {
  name = var.node_template_name
  amazonec2_config {
    access_key     = var.aws_access_key
    secret_key     = var.aws_secret_key
    ami            = var.aws_ami
    region         = var.aws_region
    security_group = [var.aws_security_group_name]
    subnet_id      = var.aws_subnet_id
    vpc_id         = var.aws_vpc_id
    zone           = var.aws_zone
    root_size      = var.aws_root_size
    instance_type  = var.aws_instance_type
  }
}

########################
# CREATE ETCD NODE POOL
########################
resource "rancher2_node_pool" "etcd_node_pool" {
  cluster_id       = rancher2_cluster.cluster.id
  name             = var.etcd_node_pool_name
  hostname_prefix  = var.node_hostname_prefix
  node_template_id = rancher2_node_template.node_template.id
  quantity         = var.etcd_node_pool_quantity
  control_plane    = false
  etcd             = true
  worker           = false
}

########################
# CREATE CP NODE POOL
########################
resource "rancher2_node_pool" "control_plane_node_pool" {
  cluster_id       = rancher2_cluster.cluster.id
  name             = var.control_plane_node_pool_name
  hostname_prefix  = var.node_hostname_prefix
  node_template_id = rancher2_node_template.node_template.id
  quantity         = var.control_plane_node_pool_quantity
  control_plane    = true
  etcd             = false
  worker           = false
}

########################
# CREATE WORKER NODE POOL
########################
resource "rancher2_node_pool" "worker_node_pool" {
  cluster_id       = rancher2_cluster.cluster.id
  name             = var.worker_node_pool_name
  hostname_prefix  = var.node_hostname_prefix
  node_template_id = rancher2_node_template.node_template.id
  quantity         = var.worker_node_pool_quantity
  control_plane    = false
  etcd             = false
  worker           = true
}