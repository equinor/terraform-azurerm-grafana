resource "azurerm_dashboard_grafana" "this" {
  name                              = var.instance_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  sku                               = "Standard"
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true
  zone_redundancy_enabled           = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
