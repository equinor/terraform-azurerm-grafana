provider "azurerm" {
  features {}
}

locals {
  app_name         = "ops-grafana"
  environment_name = "example"
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${local.app_name}-${local.environment_name}"
  location = "northeurope"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-${local.app_name}-${local.environment_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Free"
  retention_in_days   = 7
}

module "grafana" {
  source = "../.."

  app_name                   = local.app_name
  environment_name           = local.environment_name
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  grafana_version = "8.3.2"

  azuread_client_id       = "00000000-0000-0000-0000-000000000000"
  azuread_allowed_groups  = ["00000000-0000-0000-0000-000000000000"]
  azuread_allowed_domains = ["domain.com"]
}
