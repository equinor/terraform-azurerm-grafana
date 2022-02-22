output "key_vault_id" {
  description = "ID of key vault containing Grafana secrets"
  value       = module.vault.key_vault_id
}

output "postgresql_server_id" {
  description = "ID of PostgreSQL database containing Grafana data"
  value       = azurerm_postgresql_server.this.id
}

output "app_service_principal_id" {
  description = "Principal ID of app service managed identity"
  value       = azurerm_app_service.this.identity[0].principal_id
}

output "app_service_default_site_hostname" {
  description = "Default hostname of app service"
  value       = azurerm_app_service.this.default_site_hostname
}
