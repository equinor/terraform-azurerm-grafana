output "instance_name" {
  value = azurerm_dashboard_grafana.this.name
}

output "instance_id" {
  value = azurerm_dashboard_grafana.this.id
}

output "endpoint" {
  value = azurerm_dashboard_grafana.this.endpoint
}

output "grafana_version" {
  value = azurerm_dashboard_grafana.this.grafana_version
}

output "identity_principal_id" {
  value = azurerm_dashboard_grafana.this.identity[0].principal_id
}

output "identity_tenant_id" {
  value = azurerm_dashboard_grafana.this.identity[0].tenant_id
}

output "outbound_ip" {
  value = azurerm_dashboard_grafana.this.outbound_ip
}
