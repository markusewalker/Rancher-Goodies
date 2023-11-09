output "cluster_registration_token" {
  value     = rancher2_cluster.cluster.cluster_registration_token
  sensitive = true
}