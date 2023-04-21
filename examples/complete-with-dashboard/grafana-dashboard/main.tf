# data "external" "grafana_token" {
#   program = ["bash", "-c", "${path.root}/get_grafana_token.sh"]

#   query = {
#     client_id     = var.service_principal_client_id
#     client_secret = var.service_principal_client_secret
#     tenant_id     = data.azurerm_client_config.current.tenant_id
#   }

#   depends_on = [
#     azurerm_role_assignment.grafana_admin1,
#     azurerm_role_assignment.grafana_admin2,
#     azurerm_role_assignment.monitoring_reader
#   ]
# }

# provider "grafana" {
#   alias = "base"
#   url   = module.grafana.endpoint
#   auth  = data.external.grafana_token.result["token"]

#   store_dashboard_sha256 = true
# }

provider "grafana" {
  alias = "base"
  url   = module.grafana.endpoint
  auth  = var.token

  store_dashboard_sha256 = true
}

resource "grafana_folder" "my_folder" {
  provider = grafana.base

  title = "Test Folder"
}

resource "grafana_dashboard" "test" {
  provider    = grafana.base
  config_json = file("grafana-dashboard.json")

  folder    = grafana_folder.my_folder.id
  overwrite = true
}
