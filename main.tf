resource "azurerm_dashboard_grafana" "this" {
  name                              = var.instance_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
