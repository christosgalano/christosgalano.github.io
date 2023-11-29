---
title: "Azure Deployment Stacks"
excerpt: "Explore the capabilities of Azure Deployment Stacks for seamless resource orchestration and enhanced control."
tagline: "Simplify resource management in Azure with Deployment Stacks"
header:
  overlay_color: "#24292f"
  teaser: assets/images/azure/deployment-stacks/stack.webp
tags:
  - azure
  - infrastructure-as-code
toc: true
related: true
---

## Overview

In the realm of Azure resource management, deploying and managing resources across different scopes can often be a tedious and error-prone process. Deployment stacks are a new Azure feature that aims to simplify the process of managing resources across scopes. In this article, we'll look at what deployment stacks are, how they work, and how to use them.

## What is a Deployment Stack?

An Azure deployment stack is a specialized Azure resource designed to manage a group of Azure resources. It uses Bicep files or ARM JSON templates to define and control resources. The stack, identified as "Microsoft.Resources/deploymentStacks," supports 1-to-many updates and can block undesired changes. It can be accessed through Azure CLI, Azure PowerShell, or the Azure portal, following Azure RBAC for security. The focus is on efficiently managing the lifecycle of resources, including creation, updates, and deletions.

## Benefits of Deployment Stacks

Deployment stacks provide a number of benefits, including:

- **Simplified Resource Management:** Deployment stacks function as a unified entity for managing resources across scopes, streamlining provisioning and management.
- **Prevention of Undesired Modifications:** Using deny settings, deployment stacks safeguard managed resources, preventing unintended changes and maintaining control.
- **Efficient Environment Cleanup:** Delete flags in deployment stack updates enable efficient resource removal, simplifying the cleanup process after project completion.
- **Template Standardization:** Deployment stacks allow the use of standard templates such as Bicep, ARM templates, or Template specs, promoting consistency in resource deployment.

## Deployment Stacks Usage

Deployment stacks can be created using Azure CLI, Azure PowerShell, or the Azure portal. They can be deployed at resource group, subscription, or management group scope. The template provided during stack creation defines resources to be managed or updated at the specified scope. The stack can be updated to add or remove resources, and it can be deleted to remove all managed resources.

### Deployment Scopes

- **Resource Group:** A stack at this scope deploys the template to the same resource group where the deployment stack exists.
- **Subscription:** A stack at this scope deploys the template to either a specified resource group or the same subscription scope.
- **Management Group:** A stack at this scope deploys the template to the specified subscription scope.

**Important:** When creating a deployment stack the name of the deployment stack must be unique within its management scope. This means that the name of the deployment stack must be unique within the resource group, subscription or management group where the deployment stack is created. So, proper conventions must be used to avoid naming conflicts and ensure meaningful names.

{% highlight bash %}
{% raw %}
# Create a deployment stack at resource group scope
az stack group create \
  --name "$deployment_stack_name" \
  --resource-group "$resource_group_name" \
  --template-file "$template_file_path" \
  --deny-settings-mode "none"

# Create a deployment stack at subscription scope
az stack sub create \
  --name "$deployment_stack_name" \
  --location "$location" \
  --template-file "$template_file_path" \
  --deny-settings-mode "none" \
  --deployment-resource-group-name "$resource_group_name" # if not specified the managed resources are stored in subscription scope - can be skipped if the template explicitly specifies a resource group

# Create a deployment stack at management group scope
az stack mg create \
  --name "$deployment_stack_name" \
  --location "$location" \
  --template-file "$template_file_path" \
  --deny-settings-mode "none" \
  --deployment-subscription "$subscription_id" # if not specified the managed resources are stored in management group scope{% endraw %}{% endhighlight %}

### Managed and Detached Resources

Managed resources are resources that are managed by a deployment stack. Detached resources are tracked or managed by the deployment stack but still exists within Azure. By default, deployment stacks detach but do not delete unmanaged resources when they are no longer contained within the stack's management scope. In order to delete unmanaged resources, the appropriate delete flag must be set in the deployment stack update. The delete flag can be set to one of the following values:

- `delete-all`: Use delete for managed resources and resource groups.
- `delete-resources`: Use delete for managed resources only.
- `delete-resource-groups`: Use delete for managed resource groups (must be used with `delete-resources`).

### Protection of Managed Resources

Deployment stacks can be configured to protect managed resources from undesired changes. This is achieved by setting deny settings in the deployment stack. The deny settings have the following options:

- `deny-settings-mode`: Defines prohibited operations (**none**, **denyDelete**, **denyWriteAndDelete**).
- `deny-settings-apply-to-child-scopes`: Applies deny settings to nested resources.
- `deny-settings-excluded-actions`: Exclude up to 200 RBAC operations from deny settings.
- `deny-settings-excluded-principals`: Exclude up to five Microsoft Entra principal IDs.

### Update a Deployment Stack

Deployment stacks can be updated to add, remove or update resources. To modify the underlying resources, the corresponding Bicep template/s must be updated. Subsequently, the deployment stack can be updated to reflect these changes. To achieve this, one can either rerun the deployment stack create command using Azure CLI or utilize the deployment stack update command in PowerShell.

{% highlight bash %}
{% raw %}
# Update a deployment stack using Azure CLI
az stack group create \
  --name "$deployment_stack_name" \
  --resource-group "$resource_group_name" \
  --template-file "$template_file_path" \
  --deny-settings-mode "none"

# Update a deployment stack using Powershell
Set-AzResourceGroupDeploymentStack `
  --name "$deployment_stack_name" `
  -ResourceGroupName "$resource_group_name" `
  -TemplateFile "$template_file_path" `
  -DenySettingsMode "none"{% endraw %}{% endhighlight %}

- **Adding a managed resource:** add the resource definition to the underlying Bicep files, and then run the update command or rerun the create command.
- **Deleting a managed resource:** remove the resource definition from the underlying Bicep files, and then run the update command or rerun the create command.

### Delete a Deployment Stack

Deployment stacks can be deleted to remove all managed resources. The delete command can be used with the following flags:

- `delete-all`: Delete both resources and resource groups.
- `delete-resources`: Delete resources only.
- `delete-resource-groups`: Delete resource groups only.

{% highlight bash %}
{% raw %}
az stack group delete --name "$deployment_stack_name" \
  --resource-group "$resource_group_name" \
  [--delete-all/--delete-resource-groups/--delete-resources]{% endraw %}{% endhighlight %}

Running delete commands without delete flags detaches unmanaged resources but doesn't delete them.

## Examples

### Resource Group Scope

Consider a straightforward architecture comprising a virtual network, a network security group, and two storage accounts. We want to manage these resources as a single entity. We can do so by creating a deployment stack at resource group scope.

{% highlight terraform %}
{% raw %}
// File: main.bicep
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-deployment-stacks'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/23'
      ]
    }
    subnets: [
      {
        name: 'snet-001'
        properties: {
          addressPrefix: '10.1.0.0/24'
        }
      }
      {
        name: 'snet-002'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

resource storage_accounts 'Microsoft.Storage/storageAccounts@2023-01-01' = [for i in range(1, 2): {
  name: 'st${uniqueString(resourceGroup().id)}${i}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-deployment-stacks'
  location: location
}{% endraw %}{% endhighlight %}

If we were to deploy this template using a regular deployment, we would do so using the following command:

{% highlight bash %}{% raw %}az deployment group create -n "regular-deployment" -g "rg-deployment-stacks" -f "main.bicep"{% endraw %}{% endhighlight %}

Instead, to create a deployment stack we use the command below:

{% highlight bash %}
{% raw %}
# Create a stack at resource group scope
az stack group create \
  --name "demo-deployment-stack" \
  --resource-group "rg-deployment-stacks" \
  --template-file "main.bicep" \
  --deny-settings-mode "none"{% endraw %}{% endhighlight %}

![rg-stack-overview](/assets/images/azure/deployment-stacks/rg-stack-overview.webp)

Now, let's say we want to remove the network security group from the deployment stack. We can do so by removing (or commenting out) the resource definition from the underlying Bicep file and then rerun the create command.

{% highlight terraform %}
{% raw %}
...
// resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
//   name: 'nsg-deployment-stacks'
//   location: location
// }{% endraw %}{% endhighlight %}

{% highlight bash %}
{% raw %}
# Update the stack by removing the resource (detaches nsg)
az stack group create -n "demo-deployment-stack" -g "rg-deployment-stacks" -f "main.bicep" --deny-settings-mode "none" --yes{% endraw %}{% endhighlight %}

![rg-stack-nsg-detached](/assets/images/azure/deployment-stacks/rg-stack-nsg-detached.webp)

If instead we wanted to not only detach the network security group but also delete it, we could do so by adding the `--delete-resources` flag to the create command.

{% highlight bash %}
{% raw %}
# Update the stack by removing the resource (detaches nsg) and this time delete the resource (--delete-resources)
az stack group create -n "demo-deployment-stack" -g "rg-deployment-stacks" -f "main.bicep" --deny-settings-mode "none" --delete-resources --yes{% endraw %}{% endhighlight %}

![rg-stack-nsg-deleted](/assets/images/azure/deployment-stacks/rg-stack-nsg-deleted.webp)
![rg-stack-rg-overview-after-nsg-removal](/assets/images/azure/deployment-stacks/rg-stack-rg-overview-after-nsg-removal.webp)

In order to reattach the network security group, we can simply uncomment the resource definition and rerun the create command.

{% highlight terraform %}
{% raw %}
...
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-deployment-stacks'
  location: location
}{% endraw %}{% endhighlight %}

{% highlight bash %}
{% raw %}
# Update the stack by adding a new resource (attaches nsg)
az stack group create -n "demo-deployment-stack" -g "rg-deployment-stacks" -f "main.bicep" --deny-settings-mode "none" --yes{% endraw %}{% endhighlight %}

Finally, to delete the deployment stack and all managed resources we can use the delete command.

{% highlight bash %}
{% raw %}
# Delete the stack and all the managed resources (no need to specify a template)
az stack group delete -n "demo-deployment-stack" -g "rg-deployment-stacks" --delete-resources --yes{% endraw %}{% endhighlight %}

### Subscription Scope

If we wanted to manage the same resources at subscription scope, we could do so by creating a deployment stack at subscription scope. In order to do so, we would need to create a new Bicep file that references the resources in the resource group.

{% highlight terraform %}
{% raw %}
// File: subscription_scope.bicep
targetScope = 'subscription'

param location string = 'northeurope'

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-deployment-stacks-sub-scoped'
  location: location
}

module main 'main.bicep' = {
  name: 'rg-based-deployment'
  scope: resourceGroup(rg.name)
  params: {
    location: rg.location
  }
}{% endraw %}{% endhighlight %}

{% highlight bash %}
{% raw %}
# Create a stack at subscription scope
az stack sub create -n "demo-deployment-stack" -f "subscription_scope.bicep" -l "northeurope" --deny-settings-mode "none" --yes{% endraw %}{% endhighlight %}

![sub-stack-created](/assets/images/azure/deployment-stacks/sub-stack-created.webp)
![sub-stack-overview](/assets/images/azure/deployment-stacks/sub-stack-overview.webp)

Now, let's update the stack in order to prevent the deletion of managed resources.

{% highlight bash %}
{% raw %}
# Update the stack to not allow the deletion of its resources
az stack sub create -n "demo-deployment-stack" -f "subscription_scope.bicep" -l "northeurope" --deny-settings-mode "denyDelete" --yes{% endraw %}{% endhighlight %}

![sub-stack-deny-delete](/assets/images/azure/deployment-stacks/sub-stack-deny-delete.webp)

When we try to delete the network security group, we get an error.

![nsg-denied-deletion](/assets/images/azure/deployment-stacks/nsg-denied-deletion.webp)

If we wanted to allow certain users to delete the network security group, we could do so by adding their principal IDs to the deny settings.

Finally, to delete the deployment stack and all managed resources we can use the delete command.

{% highlight bash %}
{% raw %}
# Update the stack to allow the deletion of its managed resources
az stack sub create -n "demo-deployment-stack" -f "main.bicep" -l "northeurope" --deny-settings-mode "none" --yes

# Delete the stack (all resources will be deleted, including the resource groups and their resources)
az stack sub delete -n "demo-deployment-stack" --delete-all{% endraw %}{% endhighlight %}

![sub-stack-deletion](/assets/images/azure/deployment-stacks/sub-stack-deletion.webp)

## Summary

Deployment Stacks, offer a streamlined approach to managing Azure resources. Create atomic units at different scopes, implement deny settings for security, and control detachment and deletion. Efficiently update stacks by modifying Bicep files and choosing between update and create commands. This integration simplifies the management lifecycle of resources, enhancing control and security in Azure environments. Given its ease of use and the associated benefits, there is little justification for persisting with regular deployments for resource management. Deployment stacks should be preferred whenever feasible.

## Resources

- [Azure Deployment Stacks](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks)
- [Deployment Stacks Deep Dive](https://youtu.be/d1AE8qLwBYw?si=B5fFebWU4DrbgB7U)
