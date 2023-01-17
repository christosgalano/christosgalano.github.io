---
title: "Plug-and-Play Hub"
excerpt: "In today's post we see how someone can deploy a hub containing all the standard, necessary resources."
tagline: "Azure hub deployment"
header:
  overlay_color: "#24292f"
  teaser: assets/images/plug-and-play-hub/plug-and-play.jpg
categories:
  - azure
tags:
  - architecture
  - github-actions
  - iac
toc: true
related: true
---

## General

Greetings everybody! I suppose more or less all of us have used, are using, or will use the hub-spoke architecture in our Azure environment. In today's post we see how someone can deploy a hub containing all the standard, necessary resources.

You can find the Infrastructure as Code files in the [**bicep**](https://github.com/christosgalano/Plug-and-Play-Hub/tree/main/bicep) folder and the deployment script in the [**.github/scripts**](https://github.com/christosgalano/Plug-and-Play-Hub/tree/main/.github/scripts) folder.

In the [**.github/workflows**](https://github.com/christosgalano/Plug-and-Play-Hub/tree/main/.github/workflows) folder, you can also find 3 workflows:

- **deploy** which is used to deploy the infrastructure
- **destroy** which is used to destroy the infrastructure
- **psrule_scan** which is used to scan our IaC using PSRule

### Hub-Spoke architecture

A hub-spoke architecture is a common design pattern in Azure that involves creating a central "hub" resource and connecting multiple "spoke" resources to it. This architecture can be useful for a variety of purposes, including reducing complexity, improving security, and optimizing resource allocation.

One common use case for a hub-spoke architecture in Azure is to create a virtual network (VNet) as the hub resource, and then connect various Azure resources, such as virtual machines, storage accounts, and virtual appliances, to it. This allows you to manage all of these resources as a single unit, and to easily apply network security policies, access controls, and other configurations across all of the resources in the hub-spoke design.

Another benefit of a hub-spoke architecture is that it can help reduce complexity in your Azure environment. By centralizing your resources in a single hub, you can more easily manage and maintain them, rather than having to manage each resource individually. This can be especially useful if you have a large number of resources that need to be managed in a consistent way.

In terms of security, a hub-spoke architecture can be beneficial because it allows you to apply security policies and controls at the hub level, which can then be inherited by all of the connected resources. This makes it easier to ensure that all of your resources are secure and compliant, and can reduce the risk of security breaches or other vulnerabilities.

Finally, a hub-spoke architecture can help you optimize resource allocation in your Azure environment. By centralizing your resources in a single hub, you can more easily control resource utilization and ensure that your resources are being used efficiently. This can help reduce costs and improve overall performance.

Overall, a hub-spoke architecture is a useful design pattern to consider when working with Azure, as it can help to reduce complexity, improve security, and optimize resource allocation. Whether you're building a new cloud solution or migrating an existing one to Azure, a hub-spoke architecture is worth considering as a way to simplify your resource management and get the most out of your Azure environment.

## Plug-and-Play Hub

So let's go over our hub's architecture:

![architecture](/assets/images/plug-and-play-hub/architecture.jpg)

### Resources

The following resources are included in our architecture:

- [**Bastion**](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview) for connecting to virtual machines safely
- [**Firewall**](https://learn.microsoft.com/en-us/azure/firewall/overview) to safeguard our Azure cloud workloads
- [**VPN Gateway**](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways) for on-premises connectivity
- [**Azure DNS Private Resolver**](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview) to query Azure DNS private zones from an on-premises environment and vice versa
- **Log Analytics Workspace** to store all of our resources' logs and metrics
- **Key Vault** for storing sensitive information such as secrets and certificates securely
- **Storage Account** that will act as a general purpose storage container

### Network

Regarding our network topology; we have one virtual network with six subnets:

- **AzureBastionSubnet** in which the Bastion Host is located
- **AzureFirewallSubnet** where the Firewall is located
- **GatewaySubnet** which contains the VPN Gateway
- **snet-inbound** for the Azure DNS Private Resolver inbound endpoint
- **snet-outbound** for the Azure DNS Private Resolver outbound endpoint
- **snet-shared** in which reside the private endpoints

### Notes

- The VPN Gateway has two Public IPs since it is in **Active-Active** mode to ensure high availability
- Both the Key Vault (vault) and the Storage Account (blob, file) have private endpoints; the corresponding private DNS zones are created, linked to the hub virtual network, and filled with records of the private endpoints

### Configuration

There are some configuration steps that have not been performed on purpose, as they can vary between environments and client needs. Specifically:

- Firewall rules
- Forwarding ruleset for the Azure DNS Private Resolver
- Network Security Groups
- VPN connection

## Connect a spoke network

After you have successfully configured your hub, you can safely connect a spoke to it by following the below steps:

1. Create a virtual network peering between the two networks.
2. Create a virtual network link between the forwarding ruleset and the spoke network.
3. Create a route table configured with a route to the Firewall and associate with the desired spoke subnets.
4. Create rules in the Firewall accordingly.

## Summary

So, we went over the hub-spoke architecture and how we can go about deploying a basic hub containing all the standard, necessary resources. I encourage you to deploy, configure, and then experiment with it by connecting several spokes and seeing how it behaves.

**GitHub repository:** <https://github.com/christosgalano/Plug-and-Play-Hub>
