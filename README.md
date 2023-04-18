# terraform-azurerm-grafana

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![Equinor Terraform Baseline](https://img.shields.io/badge/Equinor%20Terraform%20Baseline-1.0.0-blueviolet)](https://github.com/equinor/terraform-baseline)

Terraform module which creates an Azure Managed Grafana instance.

## Limitations

- Azure Managed Grafana has a limitation when trying to log into Grafana using AAD SSO with the Firefox browser.
Firefox 91+ is only supported on Windows devices when it comes to [conditional access](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-conditions#supported-browsers).
### Fixes
- Use Firefox 91+, since it is supported for device-based Conditional Access, but "Allow Windows single sign-on for Microsoft, work, and school accounts" needs to be enabled. [Enable Windows SSO login in Firefox](https://support.mozilla.org/en-US/kb/windows-sso).

- Pursue the use of a different browser.