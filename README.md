# Azure Grafana Terraform module

Terraform module which creates an Azure Web App running a Grafana instance in a Docker container

## Configure Azure AD authentication

### Create and configure app registration

#### Register app registration

1) Open Azure Portal.
2) Navigate to "App registrations".
3) Click "New registration".
4) Set the following name: `{app_name}-{environment_name}`.
5) Set the following redirect URI: `https://{app_name}-{environment_name}.azurewebsites.net`.
6) Click "Register".

Pass the app registration client ID to the `client_id` input variable when calling this module.

#### Add owners

1) Navigate to the "Owners" page.
2) Click "Add owners".
3) Select the user(s) to assign the owner role for.
4) Click "Select".

#### Set redirect URI and front-channel logout URL

1) Navigate to the "Authentication" page.
2) Add the following redirect URI: `https://{app_name}-{environment_name}.azurewebsites.net/login/azuread`.
3) Set the following front-channel logout URL: `https://{app_name}-{environment_name}.azurewebsites.net/logout`.
4) Click "Save".

#### Create app roles roles

1) Navigate to the "App roles" page.
2) Click "Create app role" and create the following app roles:

| Display name   | Allowed member types | Value  | Description             | State   |
| -------------- | -------------------- | ------ | ----------------------- | ------- |
| Grafana Viewer | Users/Groups         | Viewer | Grafana read only users | Enabled |
| Grafana Editor | Users/Groups         | Editor | Grafana editor users    | Enabled |
| Grafana Admin  | Users/Groups         | Admin  | Grafana admin users     | Enabled |

3) Navigate to the "Manifest page" and set the following property:

```json
"groupMembershipClaims": "SecurityGroup, ApplicationGroup"
```

4) Click "Save".

#### Add client secret

1) Navigate to the "Certificates & secrets" page.
2) Click "New client secret".
3) Set the following description: `azure-webapp`.
4) Click "Add".

Store the client secret value in a key vault secret `client-secret` in the key vault `kv-{app_name}-{environment_name}` created by this module. Restart the app service `{app_name}-{environment_name}` created by this module so that it can fetch the client secret from the key vault.

### Configure enterprise application

#### Add owners

1) Open Azure Portal.
2) Navigate to "Enterprise applications".
3) Search for your app registration client ID (or display name), and select your app registration.
4) Navigate to the "Owners" page.
5) Click "Add".
6) Select the user(s) to assign the owner role for.
7) Click "Select".

#### Assign default roles

1) Navigate to the "Users and groups" page.
2) Click "Add user/group".
3) Select the user(s) and/or group(s) to assign a default role for.
4) Select the role to be assigned.
5) Click "Assign".
