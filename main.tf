locals {
  app_suffix = "${var.app_name}-${var.environment_name}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = "kv-${local.app_suffix}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "service_principal" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "Set", "Delete", "Recover"]
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "${azurerm_key_vault.this.name}-logs"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_key_vault_secret" "client_secret" {
  name         = "client-secret"
  value        = "placeholder"
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_key_vault_access_policy.service_principal
  ]

  lifecycle {
    ignore_changes = [
      value # Allow value of secret to be changed outside of Terraform
    ]
  }
}

resource "random_password" "psql" {
  length  = 32
  special = false
}

resource "azurerm_postgresql_server" "this" {
  name                = "psql-${local.app_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = "psqladmin"
  administrator_login_password = random_password.psql.result

  sku_name   = "B_Gen5_1"
  storage_mb = 15360
  version    = "11"

  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_key_vault_secret" "psql_password" {
  name         = "psql-password"
  value        = azurerm_postgresql_server.this.administrator_login_password
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_key_vault_access_policy.service_principal
  ]
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
  name                = "ap-${local.app_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "random_password" "grafana" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "grafana_password" {
  name         = "grafana-password"
  value        = random_password.grafana.result
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_key_vault_access_policy.service_principal
  ]
}

resource "azurerm_app_service" "this" {
  name                = local.app_suffix
  resource_group_name = var.resource_group_name
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.this.id
  https_only          = true

  site_config {
    linux_fx_version = "DOCKER|grafana/grafana:${var.grafana_version}"
  }

  app_settings = {
    GF_SERVER_ROOT_URL                  = "https://${local.app_suffix}.azurewebsites.net"
    GF_SECURITY_ADMIN_PASSWORD          = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.this.name};SecretName=${azurerm_key_vault_secret.grafana_password.name})"
    GF_INSTALL_PLUGINS                  = "grafana-clock-panel,grafana-simple-json-datasource,grafana-azure-monitor-datasource"
    GF_AUTH_GENERIC_OAUTH_ENABLED       = "false"
    GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP = "false"
    GF_AUTH_AZUREAD_ENABLED             = "true"
    GF_AUTH_AZUREAD_NAME                = "Azure AD"
    GF_AUTH_AZUREAD_ALLOW_SIGN_SIGN_UP  = "true"
    GF_AUTH_AZUREAD_CLIENT_ID           = var.client_id
    GF_AUTH_AZUREAD_CLIENT_SECRET       = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.this.name};SecretName=${azurerm_key_vault_secret.client_secret.name})"
    GF_AUTH_AZUREAD_SCOPE               = "openid email profile"
    GF_AUTH_AZUREAD_AUTH_URL            = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/authorize"
    GF_AUTH_AZUREAD_TOKEN_URL           = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/token"
    GF_AUTH_AZUREAD_ALLOWED_GROUPS      = join(",", var.allowed_groups)
    GF_AUTH_AZUREAD_ALLOWED_DOMAINS     = join(",", var.allowed_domains)
    GF_DATABASE_TYPE                    = "postgres"
    GF_DATABASE_HOST                    = "${azurerm_postgresql_server.this.fqdn}:5432"
    GF_DATABASE_NAME                    = azurerm_postgresql_database.this.name
    GF_DATABASE_USER                    = "${azurerm_postgresql_server.this.administrator_login}@${azurerm_postgresql_server.this.name}"
    GF_DATABASE_PASSWORD                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.this.name};SecretName=${azurerm_key_vault_secret.psql_password.name})"
    GF_DATABASE_SSL_MODE                = "require"
    GF_DATABASE_SERVER_CERT_NAME        = "*.postgres.database.azure.com"
    GF_DATABASE_CA_CERT_PATH            = "/etc/ssl/certs/ca-cert-Baltimore_CyberTrust_Root.pem" # Baltimore Cyber Trust CA certificate pre-installed on Ubuntu VM
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_app_service.this.identity[0].principal_id

  secret_permissions = ["Get"]
}
