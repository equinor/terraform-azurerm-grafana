output "instance_name" {
  description = "The name of this Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.name
}

output "instance_id" {
  description = "The ID of this Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.id
}

output "endpoint" {
  description = "The endpoint of this Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.endpoint
}

output "grafana_version" {
  description = "The version of Grafana running on this Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.grafana_version
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned identity of this Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "The tenant ID of the system-assigned identity of this Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.identity[0].tenant_id
}
