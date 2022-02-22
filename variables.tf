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

variable "psql_server_sku_name" {
  description = "SKU name for PostgreSQL server, follows the 'tier_family_cores' pattern"
  type        = string
  default     = "B_Gen5_1"
}

variable "psql_server_storage_mb" {
  description = "Max storage allowed for PostgreSQL server"
  type        = number
  default     = 15360
}

variable "psql_server_auto_grow_enabled" {
  description = "Enable/disable auto-growing of storage for PostgreSQL server"
  type        = bool
  default     = false
}

variable "psql_server_backup_retention_days" {
  description = "Backup retention days for PostgreSQL server"
  type        = number
  default     = 7
}

variable "psql_server_geo_redundant_backup_enabled" {
  description = "Turn geo-redundant backups on/off for PostgreSQL server (not supported for Basic SKU tier)"
  type        = bool
  default     = false
}

variable "psql_server_public_network_access_enabled" {
  description = "Whether or not public network access is allowed for PostgreSQL server (must be allowed for Basic SKU tier)"
  type        = bool
  default     = true
}

variable "app_service_plan_sku" {
  description = "SKU tier and size for app service plan"
  type = object({
    tier = string
    size = string
  })
  default = {
    tier = "Basic"
    size = "B1"
  }
}

variable "grafana_version" {
  description = "Version of Grafana Docker image to be pulled from Docker Hub"
  type        = string
  default     = "latest"
}

variable "azuread_client_id" {
  description = "Client ID of Azure AD app registration to be used for authentication"
  type        = string
}

variable "azuread_allowed_groups" {
  description = "Object IDs of Azure AD groups to be allowed access to Grafana instance"
  type        = list(string)
  default     = []
}

variable "azuread_allowed_domains" {
  description = "Domains to be allowed access to Grafana instance using Azure AD authentication"
  type        = list(string)
  default     = []
}
