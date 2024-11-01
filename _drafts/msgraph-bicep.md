---
title: "Microsoft Graph Bicep Extension"
excerpt: "A comprehensive guide on using the Microsoft Graph Bicep extension to manage Entra ID resources with infrastructure as code."
tagline: "Streamline Microsoft Entra ID Resource Management with the Microsoft Graph Bicep Extension"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/azure/msgraph-bicep/graph-bicep-extension.webp
tags:
  - iac
  - azure
---

## Overview

The **Microsoft Graph extension** for **Bicep** enables Azure users to manage Microsoft Graph and Azure Active Directory (Entra ID) resources using infrastructure as code (IaC). Traditionally, managing Entra ID resources required manual configuration or scripting. However, with the Bicep extension, users can now define resources such as **groups**, **applications**, and **service principals** directly within a Bicep template.

This guide explores how to use the Microsoft Graph Bicep extension to create a security group and apply role-based permissions. It provides a detailed walkthrough of syntax, usage, and key considerations.

## Architecture

The Microsoft Graph Bicep extension allows **Bicep templates** to define tenant resources beyond the traditional Azure Resource Manager scope. Here are the key capabilities of the extension:

- **Namespace**: `Microsoft.Graph` allows for the direct definition of resources in Bicep files, expanding the reach of Bicep templates to include Microsoft Graph resources.
- **Resource Types**: These include `Microsoft.Graph/groups`, `Microsoft.Graph/applications`, and various other resource types specific to Microsoft Graph.
- **Role-Based Permissions**: The extension supports the configuration of Azure role assignments for Microsoft Graph resources, which enhances secure access and governance.

![Microsoft Graph Bicep Extension](/assets/images/azure/msgraph-bicep/graph-bicep-extension.webp)

For a complete list of supported resource types, refer to the [Microsoft Graph template reference](https://learn.microsoft.com/en-us/graph/templates/reference/overview?view=graph-bicep-1.0).

## Key Benefits of the Microsoft Graph Bicep Extension

Utilizing the Microsoft Graph Bicep extension provides several advantages:

1. **Enhanced Authoring Experience**: The Bicep extension in Visual Studio Code offers rich type safety, IntelliSense, and syntax validation.
2. **Consistent Deployment**: Bicep templates ensure repeatable deployments across environments, allowing for consistent configurations of Microsoft Graph resources.
3. **Integrated Orchestration**: Bicep automatically manages interdependent resources, determining the order of operations and deploying resources in parallel whenever possible.

## Permissions

When deploying Bicep templates that involve both Azure and Microsoft Graph resources, specific permissions are essential for ensuring a smooth deployment. Since Azure and Microsoft Graph utilize different types of permissions and access mechanisms, understanding these differences is crucial for effectively managing and deploying resources.

### Access Scenarios

There are two primary methods for accessing Azure and Microsoft Graph APIs during deployment:

- **Delegated (Interactive) Access**: In this scenario, an application operates on behalf of a signed-in user. This approach is commonly used for hands-on deployments through tools like Azure CLI and PowerShell.
- **App-Only (Non-Interactive) Access**: Here, the application functions independently with its own identity, making it ideal for automated workflows, such as CI/CD pipelines.

### Permission Types

The Microsoft Graph APIs support two types of permissions based on the access scenario: delegated permissions and application permissions.

#### Delegated Permissions

These permissions are utilized in interactive access. They depend on the app's OAuth scopes and the permissions granted to the user.

![Delegated Deployments](/assets/images/azure/msgraph-bicep/delegated-deployments.webp)

#### Application Permissions

For app-only access, permissions are assigned directly to the application by an administrator, without the need for a signed-in user.

![Zero-Touch Deployments](/assets/images/azure/msgraph-bicep/app-only-deployments.webp)

> To maintain secure deployments, it is important to adhere to the principle of least privilege. This principle encourages granting only the necessary permissions required for each application's function, thereby reducing the potential impact in the event of an application compromise. By carefully setting up these permissions, you can ensure secure and efficient deployments of Azure and Microsoft Graph resources through Bicep.

## Unique Resource Names

Azure and Microsoft Graph APIs utilize different methods for creating resources, which can complicate deployments within Bicep templates:

- **Azure Resources**: These resources are created using the HTTP PUT method with a client-defined unique key (name), allowing for idempotent operations. This means that the same deployment can be repeated with consistent results.
- **Microsoft Graph Resources**: In contrast, these resources are created using the HTTP POST method, which is not idempotent and generates a unique ID (id) rather than relying on a client-defined key.

This distinction can pose challenges when deploying Microsoft Graph resources in Bicep templates. Specifically, it can hinder the ability to ensure repeatable deployments, as POST methods do not exhibit the idempotent behavior characteristic of PUT methods.

To address these challenges, client-provided keys can be utilized to achieve idempotency with Microsoft Graph resources. These keys enable an **"upsert"** mechanism (update & insert), which allows resources to be created if they do not exist or updated if they do. Examples of client-provided keys include:

- **Applications**: `uniqueName`
- **Groups**: `uniqueName`
- **Service Principals**: `appId`
- **Federated Identity Credentials**: `name`

While this client-provided key property is often an alternate key, it may sometimes serve as the primary key. Resources created without client-provided keys may require a one-time backfill of keys to support declarative redeployments. After defining these keys, resources can be included in Bicep files to ensure consistent and repeatable deployments.

## Examples

To use the Microsoft Graph Bicep extension, you need to enable the experimental feature in your Bicep configuration file. It is also advisable to use [dynamic types](https://learn.microsoft.com/en-us/graph/templates/how-to-migrate-to-dynamic-types) rather than built-in types. Below is an example of the configuration file:

{% highlight json %}
{% raw %}
{
  "experimentalFeaturesEnabled": {
    "extensibility": true
  },
  "extensions": {
    "microsoftGraphV1_0": "br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.1.8-preview"
  }
}
{% endraw %}
{% endhighlight %}

### Creating a Security Group

Here's an example of creating a security group and assigning a role-based permission using the Microsoft Graph Bicep extension:

{% highlight terraform %}
{% raw %}
extension microsoftGraphV1_0

@description('Specifies the role definition ID used in the role assignment.')
param roleDefinitionID string

@description('The unique identifier that can be assigned to a group and used as an alternate key.')
param uniqueName string

@description('The display name for the group.')
param displayName string

@description('Specifies whether the group is mail-enabled.')
param mailEnabled bool

@description('The mail alias for the group, unique for Microsoft 365 groups in the organization.')
param mailNickname string

@description('Specifies whether the group is a security group.')
param securityEnabled bool

resource group 'Microsoft.Graph/groups@v1.0' = {
  uniqueName: uniqueName
  displayName: displayName
  mailEnabled: mailEnabled
  mailNickname: mailNickname
  securityEnabled: securityEnabled
}

var roleAssignmentName = guid(uniqueName, roleDefinitionID, resourceGroup().id)
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: resourceGroup()
  properties: {
    principalId: group.id
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
  }
}
{% endraw %}
{% endhighlight %}

In this example, the Bicep template creates a security group with specified parameters and assigns role-based permissions to the group. The `uniqueName` parameter acts as the client-provided key for the group, ensuring that operations are idempotent.

One potential issue that may arise is that the instantiation of the principal or identity might not occur immediately. As a result, chained operations could fail in this scenario.

{% highlight json %}
{% raw %}
{"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-christos-galanopoulos/providers/Microsoft.Resources/deployments/deployment1","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"PrincipalNotFound","message":"Principal xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx does not exist in the directory xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx. Check that you have the correct principal ID. If you are creating this principal and then immediately assigning a role, this error might be related to a replication delay. In this case, set the role assignment principalType property to a value, such as ServicePrincipal, User, or Group.  See https://aka.ms/docs-principaltype"}]}}
{% endraw %}
{% endhighlight %}

### Creating an Application with a Service Principal

Here's an example of creating an application and its associated service principal using the Microsoft Graph Bicep extension:

{% highlight terraform %}
{% raw %}
extension microsoftGraphV1_0

@sys.description('The unique name of the application.')
param uniqueName string

@sys.description('The display name of the application.')
param displayName string = ''

@sys.description('The description of the application.')
param description string

resource app 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: uniqueName
  displayName: displayName
  description: description
}

resource sp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: app.appId
}
{% endraw %}
{% endhighlight %}

In this example, the Bicep template creates an application and its associated service principal using the specified parameters. The `uniqueName` parameter serves as the client-provided key for the application and the `appId` for the service principal, ensuring idempotent operations.

## Summary

The Microsoft Graph Bicep extension offers a powerful way to manage Microsoft Graph and Azure Entra ID resources using infrastructure as code. By defining resources directly in Bicep templates, users can streamline deployments, enhance security, and ensure consistent configurations across environments.

## Resources

- [**Microsoft Graph Bicep Extension**](https://learn.microsoft.com/en-us/graph/templates/overview-bicep-templates-for-graph)
- [**Quickstart Templates**](https://github.com/microsoftgraph/msgraph-bicep-types/tree/main/quickstart-templates)
