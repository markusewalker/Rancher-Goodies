########################
# RANCHER VARIABLES
########################
rancher_api_url            = ""
rancher_admin_bearer_token = ""

########################
# AWS VARIABLES
########################
aws_access_key          = ""
aws_secret_key          = ""
aws_ami                 = ""
aws_instance_type       = ""
aws_region              = "us-east-2"
aws_security_group_name = ""
aws_subnet_id           = ""
aws_vpc_id              = ""
aws_zone                = "a"
aws_root_size           = 100

########################
# RKE VARIABLES
########################
cluster_name                                               = ""
network_plugin                                             = ""
node_template_name                                         = ""
etcd_node_pool_name                                        = ""
etcd_node_pool_quantity                                    = 3
control_plane_node_pool_name                               = ""
control_plane_node_pool_quantity                           = 2
worker_node_pool_name                                      = ""
worker_node_pool_quantity                                  = 3
node_hostname_prefix                                       = ""
kubernetes_version                                         = ""
default_pod_security_admission_configuration_template_name = ""