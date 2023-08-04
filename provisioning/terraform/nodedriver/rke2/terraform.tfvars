########################
# RANCHER VARIABLES
########################
rancher_api_url            = "https://..."
rancher_admin_bearer_token = ""

########################
# AWS VARIABLES
########################
aws_access_key      = ""
aws_secret_key      = ""
machine_config_name = ""
ami                 = ""
region              = "us-east-2"
security_group      = ""
subnet_id           = ""
vpc_id              = ""
zone                = "a"

########################
# K3S VARIABLES
########################
cluster_name                             = ""
kubernetes_version                       = "v1.26.6+rke2r1"
default_cluster_role_for_project_members = "user"
machine_pool_etcd_name                   = ""
machine_pool_etcd_quantity               = 1
machine_pool_control_plane_name          = ""
machine_pool_control_plane_quantity      = 1
machine_pool_worker_name                 = ""
machine_pool_worker_quantity             = 1
cloud_credential_name                    = ""