provider "azurerm" {
  features {}
}

resource "random_id" "example" {
  byte_length = 8
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${random_id.example.hex}"
  location = var.location
}

module "log_analytics" {
  source = "github.com/equinor/terraform-azurerm-log-analytics?ref=v1.3.1"

  workspace_name      = "log-${random_id.example.hex}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

module "grafana" {
  source = "../.."

  instance_name              = "dg-${random_id.example.hex}"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

data "azurerm_subscription" "current" {}

# Give Managed Grafana instances access to read monitoring data in current subscription.
resource "azurerm_role_assignment" "monitoring_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Monitoring Reader"
  principal_id         = module.grafana.identity_principal_id
}

data "azurerm_client_config" "current" {}

# Give current client admin access to Managed Grafana instance.
resource "azurerm_role_assignment" "grafana_admin" {
  scope                = module.grafana.instance_id
  role_definition_name = "Grafana Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

# data "external" "grafana_token" {
#   program = ["bash", "-c", "${path.module}/scripts/get_grafana_token.sh"]

#   query = {
#     client_id     = var.service_principal_client_id
#     client_secret = var.service_principal_client_secret
#     tenant_id     = data.azurerm_client_config.current.tenant_id
#   }

#   depends_on = [
#     azurerm_role_assignment.grafana_admin,
#     azurerm_role_assignment.monitoring_reader
#   ]
# }

# provider "grafana" {
#   alias = "base"
#   url   = module.grafana.endpoint
#   auth  = data.external.grafana_token.result["token"]

#   store_dashboard_sha256 = true
# }

# resource "grafana_folder" "my_folder" {
#   provider = grafana.base

#   title = "Test Folder"
# }

# resource "grafana_dashboard" "test" {
#   provider    = grafana.base
#   config_json = file("grafana-dashboard.json")
#   folder      = grafana_folder.my_folder.id
#   overwrite   = true
# }
