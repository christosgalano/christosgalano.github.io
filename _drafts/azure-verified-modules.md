---
title: "Azure Verified Modules"
excerpt: "Azure Verified Modules (AVM) are standardized, supported Infrastructure as Code (IaC) modules for deploying Azure resources, ensuring best practices and consistency across your cloud infrastructure."
tagline: "Streamlining Azure Deployments with Verified Modules"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/azure/azure-verified-modules/avm.webp
tags:
  - azure
  - infrastructure-as-code
---

## Overview

In today's fast-paced cloud landscape, consistency, reliability, and adherence to best practices are crucial. Azure Verified Modules (AVM) address these needs by providing pre-defined, reusable Infrastructure as Code (IaC) modules developed and maintained by Microsoft for both Bicep and Terraform. They streamline Azure resource deployment, simplifying infrastructure management while ensuring compliance with Microsoft's well-architected framework (WAF). Whether for a small-scale application or a complex architecture, AVM modules provide a reliable foundation for Azure deployments, supported by Microsoft's robust assistance and updates.

## Definition

Azure Verified Modules (AVM) offer a consistent approach to deploying and managing Azure resources, developed and supported by Microsoft to meet best practices and compliance requirements. These pre-defined, reusable modules for Infrastructure as Code (IaC) facilitate Azure resource deployment and management, available for both Bicep and Terraform. AVM ensures consistency and adherence to Microsoft's well-architected framework (WAF), making cloud infrastructure management more efficient and reliable.

## Development and Quality Standards

Each AVM module undergoes a meticulous development process to ensure high quality and compliance with best practices:

- **Design and Specification**: Detailed design phases ensure each module meets Azure's architectural and security standards.
- **Coding and Implementation**: Modules are implemented using IaC languages like Bicep and Terraform, following strict coding standards.
- **Automated Testing**: Comprehensive tests, including unit and integration tests, ensure module functionality and reliability.
- **Documentation Generation**: Automatically generated documentation provides clear instructions for users.
- **Review and Approval**: Rigorous reviews by Azure engineers ensure modules meet quality and security standards.

AVM modules are organized in a well-structured repository with clear directories for different resource types and services. Each module is versioned for easy updates and backward compatibility. Regular updates incorporate new features, improvements, and security patches. Published AVM modules are available in public repositories, such as the Azure Verified Modules GitHub repository, and are integrated with tools like the Azure Developer CLI (azd) and the Bicep Registry.

## Benefits

- **Standardization and Consistency**: AVM modules follow a standardized structure and best practices, ensuring consistency across deployments.
- **Support and Longevity**: Officially supported by Microsoft, AVM modules are regularly updated to align with the latest Azure services and features.
- **Language-Agnostic**: Available for Bicep and Terraform, AVM caters to a wide range of IaC preferences and tools.
- **Compliance and Best Practices**: AVM modules are aligned with high-priority recommendations from frameworks like WAF and security benchmarks, ensuring robust and secure deployments.
- **Automated Documentation and Testing**: With built-in support for automated documentation generation and comprehensive testing, AVM modules are easy to use and reliable.

## Module Classifications

AVM defines two primary classifications for modules: Resource Modules and Pattern Modules. These classifications help users understand the scope and intended use of each module type.

### Resource Modules

Resource Modules are designed to deploy a primary Azure resource configured with high-priority best practices from the Well-Architected Framework (WAF). These modules often include related resources necessary for the primary resource to function properly, ensuring a seamless deployment experience. However, they do not deploy external dependencies for the primary resource.

These modules are ideal for deploying individual Azure resources while adhering to WAF best practices. They can be used independently or combined with other Resource Modules to create more complex architectures.

### Pattern Modules

Pattern Modules are designed to deploy multiple Azure resources together, often using existing Resource Modules. They aim to accelerate the deployment of common architectures or tasks and can include other Pattern Modules, but must not reference non-AVM modules.

Pattern Modules are suitable for deploying complex architectures or implementing specific patterns using a combination of Resource Modules. They provide a higher-level abstraction for deploying multiple resources together, streamlining the deployment process.

## How to Use Azure Verified Modules

Using Azure Verified Modules involves selecting the appropriate module, integrating it into your IaC scripts, and deploying it. Below, we detail the steps along with examples in both Terraform and Bicep.

### Steps to Use AVM

1. **Select a Module**: Browse the AVM repository to find the module that fits your needs. Each module is categorized and comes with detailed documentation.
2. **Integrate with Your IaC**: Download the module and integrate it into your existing Bicep or Terraform scripts. Follow the provided instructions for seamless integration.
3. **Deploy the Module**: Use your integrated IaC scripts to deploy the selected AVM module and manage your Azure resources efficiently.

### Example Usage with Terraform

Here's an example of using an AVM module that deploys a production standard AKS cluster along with supporting a virtual network and Azure container registry:

{% highlight terraform %}
{% raw %}
# main.tf
module "avm-ptn-aks-production" {
  source  = "Azure/avm-ptn-aks-production/azurerm"
  version = "0.1.0"
  
  kubernetes_version  = "1.28"
  name                = "aks-production"
  resource_group_name = "rg-aks-production"
  
  managed_identities = {
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  location = "North Europe"
  node_pools = {
    workload = {
      name                 = "workload"
      vm_size              = "Standard_D2d_v5"
      orchestrator_version = "1.28"
      max_count            = 110
      min_count            = 2
      os_sku               = "Ubuntu"
      mode                 = "User"
    },
    ingress = {
      name                 = "ingress"
      vm_size              = "Standard_D2d_v5"
      orchestrator_version = "1.28"
      max_count            = 4
      min_count            = 2
      os_sku               = "Ubuntu"
      mode                 = "User"
    }
  }
}
{% endraw %}
{% endhighlight %}

### Example Usage with Bicep

Here's an example of using an AVM module that deploys a resource role assignment:

{% highlight terraform %}
{% raw %}
// main.bicep
module resourceRoleAssignment 'br/public:avm/ptn/authorization/resource-role-assignment:<version>' = {
  name: 'resourceRoleAssignmentDeployment'
  params: {
    // Required parameters
    principalId: '<principalId>'
    resourceId: '<resourceId>'
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

    // Non-required parameters
    description: 'Assign Storage Blob Data Reader role to the managed identity on the storage account.'
    principalType: 'ServicePrincipal'
    roleName: 'Storage Blob Data Reader'
  }
}
{% endraw %}
{% endhighlight %}

## Summary

Azure Verified Modules provide a robust, standardized approach to deploying Azure resources. By leveraging these modules, organizations can ensure consistency, reliability, and compliance across their cloud infrastructure. The detailed development process and rigorous quality standards behind AVM modules guarantee that they meet the highest levels of performance and security, making them an invaluable tool for any Azure deployment strategy.

## Resources

- [**Azure Verified Modules**](https://azure.github.io/Azure-Verified-Modules/)
- [**Azure Verified Modules GitHub Repository**](https://github.com/Azure/Azure-Verified-Modules)
- [**Bicep Public Module Registry**](https://github.com/Azure/bicep-registry-modules)
