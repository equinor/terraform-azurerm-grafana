variable "location" {
  description = "The location to create the resources in."
  type        = string
  default     = "northeurope"
}

# variable "service_principal_client_id" {
#   type    = string
#   default = "7a2ba5d9-d06e-466a-83d5-0284953a1f15"
#   # sensitive = true
# }

# variable "service_principal_client_secret" {
#   type      = string
#   default   = "QB48Q~LK2hqYpQaoTJCSCw.geL-t5hRTa5qy-cI2"
#   sensitive = true
# }

# export TF_VAR_token=$(az grafana api-key create --key `date +%s` --name dg-{name} -g rg-{name} -r editor --time-to-live 15m -o json | jq -r .key)
variable "token" {
  type      = string
  nullable  = false
  sensitive = true
}

# export TF_VAR_url=$(az grafana show -g rg-{name} -n dg-{name} -o json | jq -r .properties.endpoint)
