# Terraform module for Azure Managed Grafana

[![GitHub License](https://img.shields.io/github/license/equinor/terraform-azurerm-grafana)](https://github.com/equinor/terraform-azurerm-grafana/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/equinor/terraform-azurerm-grafana)](https://github.com/equinor/terraform-azurerm-grafana/releases/latest)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![SCM Compliance](https://scm-compliance-api.radix.equinor.com/repos/equinor/terraform-azurerm-grafana/badge)](https://developer.equinor.com/governance/scm-policy/)

Terraform module which creates Azure Managed Grafana resources.

## Features

- Creates a managed Grafana instance in the given resource group.
- Audit logs sent to given Log Analytics workspace by default.

## Prerequisites

- Azure role `Contributor` at the resource group scope.
- Azure role `Log Analytics Contributor` at the Log Analytics workspace scope.

## Usage

```terraform
provider "azurerm" {
  features {}
}

module "grafana" {
  source  = "equinor/grafana/azurerm"
  version = "~> 2.2"

  instance_name              = "example-grafana"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "westeurope"
}

module "log_analytics" {
  source  = "equinor/log-analytics/azurerm"
  version = "~> 2.3"

  workspace_name      = "example-workspace"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}
```

## Known Issues

### Unable to login using the Firefox browser

Azure Managed Grafana has a limitation when trying to log into Grafana using AAD SSO with the Firefox browser.
Firefox 91+ is only supported on Windows devices when it comes to [conditional access](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-conditions#supported-browsers).

To resolve this issue, do either of the following:

- Use Firefox 91+, since it is supported for device-based Conditional Access, but "Allow Windows single sign-on for Microsoft, work, and school accounts" needs to be enabled. [Enable Windows SSO login in Firefox](https://support.mozilla.org/en-US/kb/windows-sso).
- Pursue the use of a different browser.

## Contributing

See [Contributing guidelines](https://github.com/equinor/terraform-baseline/blob/main/CONTRIBUTING.md).
