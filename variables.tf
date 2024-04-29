variable "instance_name" {
  description = "The name of this managed Grafana instance."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the resources in."
  type        = string
}

variable "location" {
  description = "The location to create the resources in."
  type        = string
}

variable "grafana_major_version" {
  description = "Which major version of Grafana to deploy."
  type        = string
  default     = "9"
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace to send diagnostics to."
  type        = string
}

variable "diagnostic_setting_name" {
  description = "The name of this Diagnostic Setting."
  type        = string
  default     = "audit-logs"
}

variable "diagnostic_setting_enabled_log_categories" {
  description = "A list of log categories to be enabled for this diagnostic setting."
  type        = list(string)
  default     = ["GrafanaLoginEvents"]
}

variable "diagnostic_setting_enabled_metric_categories" {
  description = "A list of metric categories to be enabled for this diagnostic setting."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
