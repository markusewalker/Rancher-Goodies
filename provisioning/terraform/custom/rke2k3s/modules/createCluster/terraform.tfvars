########################
# RANCHER VARIABLES
########################
rancher_api_url            = ""
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
cluster_name                                               = ""
kubernetes_version                                         = ""
default_cluster_role_for_project_members                   = "user"
default_pod_security_admission_configuration_template_name = "rancher-restricted"