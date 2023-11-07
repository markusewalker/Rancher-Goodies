variable "rancher_api_url" {
  type        = string
  description = "Rancher URL"
}

variable "rancher_admin_bearer_token" {
  type        = string
  description = "Admin bearer token"
}

variable "google_credential_file_path" {
  type        = string
  description = "Google credential file path"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "network" {
  type        = string
  description = "Network"
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork"
}

variable "initial_node_count" {
  type        = number
  description = "Initial node count"
}

variable "max_pods_constraint" {
  type        = number
  description = "Max pods constraint"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "cloud_credential_name" {
  type        = string
  description = "Cloud credential name"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "node_pool_name" {
  type        = string
  description = "Node pool name"
}

variable "node_pool_version" {
  type        = string
  description = "Node pool version"
}