variable "app_name" {
  type    = string
  default = "grafana"
}

variable "environment_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "log_analytics_workspace_id" {
  description = "ID of Log Analytics workspace to store Azure Monitor logs in"
  type        = string
}

variable "grafana_version" {
  description = "Version of Grafana Docker image to be pulled from Docker Hub"
  type        = string
  default     = "latest"
}

variable "client_id" {
  description = "Client ID of Azure AD app registration to be used for authentication"
  type        = string
}

variable "allowed_groups" {
  description = "Object IDs of Azure AD groups to be allowed access to Grafana instance"
  type        = list(string)
  default     = []
}

variable "allowed_domains" {
  description = "Domains to be allowed access to Grafana instance"
  type        = list(string)
  default     = []
}
