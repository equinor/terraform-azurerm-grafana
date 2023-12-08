provider "azurerm" {
  features {}
}

resource "random_id" "example" {
  byte_length = 8
}

module "log_analytics" {
  source = "github.com/equinor/terraform-azurerm-log-analytics?ref=v2.1.1"

  workspace_name      = "log-${random_id.example.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "grafana" {
  source = "../.."

  instance_name              = "dg-${random_id.example.hex}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
}
