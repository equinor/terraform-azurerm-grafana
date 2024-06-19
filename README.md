# terraform-azurerm-grafana

[![SCM Compliance](https://scm-compliance-api.radix.equinor.com/repos/equinor/terraform-azurerm-grafana/badge)](https://scm-compliance-api.radix.equinor.com/repos/equinor/terraform-azurerm-grafana/badge)
[![Equinor Terraform Baseline](https://img.shields.io/badge/Equinor%20Terraform%20Baseline-1.0.0-blueviolet)](https://github.com/equinor/terraform-baseline)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)

Terraform module which creates an Azure Managed Grafana instance.

## Development

1. Read [this document](https://code.visualstudio.com/docs/devcontainers/containers).

1. Clone this repository.

1. Configure Terraform variables in a file `.devcontainer/devcontainer.env`:

    ```env
    TF_VAR_resource_group_name=
    TF_VAR_location=
    ```

1. Open repository in dev container.

## Testing

1. Change to the test directory:

    ```console
    cd test
    ```

1. Login to Azure:

    ```console
    az login
    ```

1. Set active subscription:

    ```console
    az account set -s <SUBSCRIPTION_NAME_OR_ID>
    ```

1. Run tests:

    ```console
    go test -timeout 60m
    ```

## Limitations

- Azure Managed Grafana has a limitation when trying to log into Grafana using AAD SSO with the Firefox browser.
Firefox 91+ is only supported on Windows devices when it comes to [conditional access](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-conditions#supported-browsers).

### Fixes

- Use Firefox 91+, since it is supported for device-based Conditional Access, but "Allow Windows single sign-on for Microsoft, work, and school accounts" needs to be enabled. [Enable Windows SSO login in Firefox](https://support.mozilla.org/en-US/kb/windows-sso).

- Pursue the use of a different browser.

## Contributing

See [Contributing guidelines](https://github.com/equinor/terraform-baseline/blob/main/CONTRIBUTING.md).
