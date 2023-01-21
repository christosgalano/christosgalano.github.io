---
title: "Blue/Green AKS: Part 1 - Architecture"
excerpt: "In today’s blog post, we look into the Azure architecture of our blue/green deployment."
tagline: "Azure architecture of the blue/green deployment"
header:
  overlay_color: "#24292f"
categories:
  - azure
  - kubernetes
tags:
  - blue-green
  - architecture
toc: true
related: true
---

![architecture](/assets/images/blue-green-aks/architecture.jpg)

## General

All of the things mentioned below are specified in the [**bicep**](https://github.com/christosgalano/Blue-Green-AKS/tree/main/bicep) templates.

So, let's go over our infrastructure's architecture.

We have two AKS instances one blue and one green. Initially the blue will be the primary one; when saying primary from now on we will mean the public-facing, live cluster.

Each cluster has an Application Gateway with WAF that acts as its Ingress Controller.

In order to perform a switch between environments we use [Traffic Manager with Priority-based routing method](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-routing-methods#priority-traffic-routing-method).

Because the clusters are private we also need a virtual machine that acts as a jumpbox server and a Bastion host to safely connect to it.

We store images in our Container Registry and sensitive information like the virtual machine's admin password in our Key Vault. Both resources have private endpoints.

In order to take care of monitoring we deploy a Log Analytics Workspace and we enable Container-Insights for both AKS instances.

Both clusters share a user-assigned managed identity.

We create two route tables; one blue and one green. We associate the blue route table with blue AKS subnet and the blue Application Gateway subnet and the green route table with the green ones. In this way, when we deploy the AKS instances the appropriate routes will be created in each route table.

### Resources

We split the resources in two different resource groups, one for aks-related resources and one for common resources.

The aks resource group contains the following resources:

- an aks-related **virtual network**
- two **AKS** (blue and green)
- two **Application Gateways** which act as Ingress Controller for the corresponding cluster (blue or green)
- two **Public IPs**; one for each Application Gateway
- two **Web Application Firewall Policies**; one for each Application Gateway
- a **user-assigned managed identity** used for the clusters
- two **Route Tables**

The common resource group contains the following resources:

- a common-related **virtual network**
- a **Bastion** host and its **Public IP**
- a **Log Analytics Workspace**
- a **Key Vault** with **Private Endpoint** and the corresponding **Private DNS Zone**
- a **Container Registry** with **Private Endpoint** and the corresponding **Private DNS Zone**
- a **Virtual Machine** that acts as a jumpbox server to provide connectivity and manage the resources
- a **Traffic Manager Profile**

### Network

As you can see we create two virtual networks, one for aks-related resources and one for common resources.

The aks virtual network consists of 4 subnets:

- **nodes-blue**: where the Virtual Machine Scales Sets of the blue AKS reside
- **nodes-green**: where the Virtual Machine Scales Sets of the green AKS reside
- **ingress-blue**: where the Application Gateway that acts as Ingress Controller of the blue AKS reside
- **ingress-green**: where the Application Gateway that acts as Ingress Controller of the green AKS reside

The common virtual network consists of 3 subnets:

- **pep**: where the private endpoints of the resources reside
- **management**: which contains the network interface card of the jumpbox virtual machine
- **bastion**: which contains the Bastion host

### Jumpbox server

After the virtual machine has been created, it uses the script [**scripts/setup_jumpbox.tpl**](https://github.com/christosgalano/Blue-Green-AKS/blob/main/.github/scripts/setup_jumpbox.tpl) to install some necessary tools.

### AKS add-ons

We enable the following add-ons in each cluster:

- **omsAgent**: to monitor the cluster
- **azureKeyvaultSecretsProvider**: to pull information from Key Vaults
- **ingressApplicationGateway**: to enable Application Gateway as Ingress Controller

Each add-on will get assigned its own user-assigned managed identity which will reside in the corresponding cluster's resource group.

### Identity

We assign the ***clusters' identity*** the Contributor role over the aks resource group, so that we can modify the route tables.

We assign the ***jumpbox identity*** the Contributor role over the aks resource group, so that we can connect to the clusters.

We assign both (blue and green) the ***ingressApplicationGateway identities*** the Contributor role over the aks resource group, so that we can perform changes in the Application Gateways.

We also assign both (blue and green) the ***kubelet identities*** the AcrPull role over the common resource group, so that we can pull images from the container registry. The kubelet identity is basically the identity assigned to the VMSS.

Finally, we create access policies in the Key Vault for the ***identities azureKeyvaultSecretsProvider, ingressApplicationGateway, jumpbox, actor_id***.

## Summary

That pretty much covers the details of our infrastructure. In the next part, we are going to cover the deployment of a sample application and how we can perform a switch between environments.

**Next part:**

- **Part 2: Usage**

**Previous parts:**

- [**Part 0: Introduction**]({% post_url 2023-xx-yy-blue-green-aks-introduction %})

**GitHub repository:** <https://github.com/christosgalano/Blue-Green-AKS>
