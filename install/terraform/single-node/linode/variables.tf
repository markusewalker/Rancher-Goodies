variable "linode_token" {
  type        = string
  description = "Defines the Linode API token"
}

variable "linode_label" {
  type        = string
  description = "Defines the Linode instance label"
}

variable "linode_image" {
  type        = string
  description = "Defines the Linode image"
}

variable "linode_region" {
  type        = string
  description = "Defines the Linode region"
}

variable "linode_type" {
  type        = string
  description = "Defines the Linode instance type"
}

variable "linode_root_pass" {
  type        = string
  description = "Defines the Linode root password"
}

variable "linode_tags" {
  type        = string
  description = "Defines the Linode tags"
}

variable "ssh_connection_type" {
  type        = string
  description = "Defines the SSH connection type"
}

variable "linode_user" {
  type        = string
  description = "Defines the Linode user"
}

variable "rancher_password" {
  type        = string
  description = "Defines the Rancher password"
}

variable "rancher_tag_version" {
  type        = string
  description = "Defines the Rancher tag version"
}

variable "ssh_timeout" {
  type        = string
  description = "Defines the SSH timeout"
}