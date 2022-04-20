locals {
  app_service_name = "${var.app_name}-${var.environment_name}"
}

data "azurerm_client_config" "current" {}

module "vault" {
  source = "github.com/equinor/terraform-azurerm-vault?ref=c4da70f23236927bb789594b4a033e9b3a3b1173"

  app_name                   = var.app_name
  environment_name           = var.environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "random_password" "psql" {
  length  = 32
  special = false
}

resource "azurerm_postgresql_server" "this" {
  name                = "psql-${local.app_service_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = "psqladmin"
  administrator_login_password = random_password.psql.result

  sku_name   = var.psql_server_sku_name
  storage_mb = var.psql_server_storage_mb
  version    = "11"

  auto_grow_enabled                 = var.psql_server_auto_grow_enabled
  backup_retention_days             = var.psql_server_backup_retention_days
  geo_redundant_backup_enabled      = var.psql_server_geo_redundant_backup_enabled
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_key_vault_secret" "psql_password" {
  name         = "psql-password"
  value        = azurerm_postgresql_server.this.administrator_login_password
  key_vault_id = module.vault.key_vault_id
}

resource "azurerm_postgresql_firewall_rule" "this" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.this.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_postgresql_database" "this" {
  name                = "grafana"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.this.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_app_service_plan" "this" {
  name                = "ap-${local.app_service_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = var.app_service_plan_sku.tier
    size = var.app_service_plan_sku.size
  }
}

resource "random_password" "grafana" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "grafana_password" {
  name         = "grafana-password"
  value        = random_password.grafana.result
  key_vault_id = module.vault.key_vault_id
}

resource "azurerm_app_service" "this" {
  name                = local.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.this.id
  https_only          = true

  site_config {
    linux_fx_version = "DOCKER|grafana/grafana:${var.grafana_version}"
  }

  app_settings = {
    GF_SERVER_ROOT_URL                  = "https://${local.app_service_name}.azurewebsites.net"
    GF_SECURITY_ADMIN_PASSWORD          = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.grafana_password.versionless_id}/)"
    GF_INSTALL_PLUGINS                  = "grafana-clock-panel,grafana-simple-json-datasource"
    GF_AUTH_GENERIC_OAUTH_ENABLED       = "false"
    GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP = "false"
    GF_AUTH_AZUREAD_ENABLED             = "true"
    GF_AUTH_AZUREAD_NAME                = "Azure AD"
    GF_AUTH_AZUREAD_ALLOW_SIGN_UP       = "true"
    GF_AUTH_AZUREAD_CLIENT_ID           = var.azuread_client_id
    GF_AUTH_AZUREAD_CLIENT_SECRET       = "@Microsoft.KeyVault(VaultName=${module.vault.key_vault_name};SecretName=client-secret)"
    GF_AUTH_AZUREAD_SCOPE               = "openid email profile"
    GF_AUTH_AZUREAD_AUTH_URL            = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/authorize"
    GF_AUTH_AZUREAD_TOKEN_URL           = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/token"
    GF_AUTH_AZUREAD_ALLOWED_GROUPS      = join(",", var.azuread_allowed_groups)
    GF_AUTH_AZUREAD_ALLOWED_DOMAINS     = join(",", var.azuread_allowed_domains)
    GF_DATABASE_TYPE                    = "postgres"
    GF_DATABASE_HOST                    = "${azurerm_postgresql_server.this.fqdn}:5432"
    GF_DATABASE_NAME                    = azurerm_postgresql_database.this.name
    GF_DATABASE_USER                    = "${azurerm_postgresql_server.this.administrator_login}@${azurerm_postgresql_server.this.name}"
    GF_DATABASE_PASSWORD                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.psql_password.versionless_id}/)"
    GF_DATABASE_SSL_MODE                = "require"
    GF_DATABASE_SERVER_CERT_NAME        = "*.postgres.database.azure.com"
    GF_DATABASE_CA_CERT_PATH            = "/etc/ssl/certs/ca-cert-Baltimore_CyberTrust_Root.pem" # Baltimore Cyber Trust CA certificate pre-installed on Ubuntu VM
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = module.vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_app_service.this.identity[0].principal_id

  secret_permissions = ["Get"]
}
