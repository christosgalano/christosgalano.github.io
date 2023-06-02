---
title: "Blue/Green AKS"
excerpt: "TODO: Add excerpt"
tagline: "TODO: Add tagline"
header:
  overlay_color: "#24292f"
  teaser: #TODO add teaser
categories:
  - kubernetes
  - azure
tags:
  - aks
toc: true
---

## General

<!-- TODO: Add general info -->

## Blue/Green deployment

Blue/green deployment is a software deployment strategy that involves running two identical production environments, called blue and green. At any given time, only one of the environments is live and serving production traffic, while the other is idle and can be used for testing or as a failover in case of an issue with the live environment.

One of the main benefits of blue/green deployment is that it allows for minimal downtime during the deployment process. When a new version of an application is ready to be deployed, it is first tested in the idle green environment. Once the green environment has been tested and is confirmed to be working correctly, traffic is switched over from the blue environment to the green environment. This switchover can be done quickly, allowing for a seamless transition from one version of the application to the next with minimal disruption to users.

Another advantage of blue/green deployment is the ability to easily roll back to a previous version of the application if necessary. If there are any issues with the new version of the application running in the green environment, traffic can be quickly switched back to the blue environment, which is running the previous version of the application. This allows for a quick resolution of any issues that may arise during the deployment process.

Blue/green deployment is also useful in environments where it is important to minimize risk. By running two identical production environments, it is possible to ensure that there is always a failover option available in case of an issue with the live environment.

Overall, blue/green deployment is a useful tool for minimizing downtime and risk during the deployment of applications. It can be used in a variety of different environments and is particularly well-suited for applications that require a high level of availability.

## Architecture

![architecture](/assets/images/blue-green-aks/architecture.webp)

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

After the virtual machine has been created, it uses the script [**scripts/setup_jumpbox.tpl**](/.github/scripts/setup_jumpbox.tpl) to install some necessary tools.

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

## Infrastructure deployment

You can find the Infrastructure as Code files in the [**bicep**](/bicep) folder and the deployment script in the [**.github/scripts**](/.github/scripts) folder.

In the [**.github/workflows**](/.github/workflows) folder, you can also find 2 workflows:

- **deploy** which is used to deploy the infrastructure
- **destroy** which is used to destroy the infrastructure

## Configure DNS

First of all you need to have your own domain. If you don't have a domain, one simple solution is to purchase one using [App Service Domain](https://learn.microsoft.com/en-us/azure/app-service/manage-custom-dns-buy-domain).

Next, create a CNAME record in the domain's DNS Zone providing the Traffic Manager's endpoint.

![cname-record](/assets/images/blue-green-aks/cname_record.webp)

## Application deployment

For the sample application, [podinfo](https://github.com/stefanprodan/podinfo) repository by [Stefan Prodan](https://github.com/stefanprodan) is being used.

You can find all the manifests inside the [**manifests/podinfo**](https://github.com/christosgalano/Blue-Green-AKS/tree/main/manifests/podinfo) folder.

In order to deploy the application you need to perform the following steps:

1. In the **manifests/podinfo/ingress.yaml** file replace the host value
2. Connect to the jumpbox virtual machine using Bastion (use the password stored in the Key Vault)
3. Copy the files from **manifests/podinfo** folder
4. Run the following block:

```bash
az login --identity
az aks get-credentials --resource-group <aks-rg-name> --name <blue-aks-name>
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

Do the same for the green cluster.

## Traffic Manager

### Configuration

If you did not prove a hostname value when deploying the infrastructure then you need to provide a custom header setting in the Traffic Manager's configuration.

We need to set the hostname under custom header settings to let the Ambassador know to which container application in the Kubernetes cluster it should forward the endpoint monitoring request.

![tf-config](/assets/images/blue-green-aks/tf_config.webp)

Replace the existing sample domain with your own.

### Endpoints

Initially both endpoints of the Traffic Manager are disabled.

![disabled-endpoints](/assets/images/blue-green-aks/disabled-endpoints.webp)

Enable both endpoints.

![enable-blue-endpoint](/assets/images/blue-green-aks/enable-blue-endpoint.webp)

Now we can see that both endpoints are enabled with an online status.

![online-endpoints](/assets/images/blue-green-aks/online-endpoints.webp)

## Switch

### Blue online

The Traffic Manager resolves to the blue endpoint since it has lower priority than the green one and it is online.

![blue-dns](/assets/images/blue-green-aks/blue-dns.webp)

So, the live application is the one deployed in the blue cluster.

![blue-online](/assets/images/blue-green-aks/blue-online.webp)

![blue-pod](/assets/images/blue-green-aks/blue-pod.webp)

### Perform a switch

Now let's say something goes wrong in the blue cluster. In this case we are going to delete the ingress resource so the blue endpoint becomes degraded.

![delete-blue-ingress](/assets/images/blue-green-aks/delete-blue-ingress.webp)

We can see that after a bit (depends on the Configuration values) the Traffic Manager resolves to the green endpoint which is the one that has the lowest priority and is online.

![green-dns](/assets/images/blue-green-aks/green-dns.webp)

So, the live application is the one deployed in the green cluster.

![green-online](/assets/images/blue-green-aks/green-online.webp)

![green-pod](/assets/images/blue-green-aks/green-pod.webp)

### Restore blue endpoint

Now let's restore the blue endpoint by recreating the ingress resource. Run the following:

{% highlight bash %}
az aks get-credentials --resource-group <aks-rg-name> --name <blue-aks-name>
kubectl apply -f ingress.yaml
{% endhighlight %}

After a bit we can see that the blue endpoint has been restored.

![blue-dns-restored](/assets/images/blue-green-aks/blue-dns-restored.webp)

So, the live application is once again the one deployed in the blue cluster.

![blue-online-restored](/assets/images/blue-green-aks/blue-online-restored.webp)

![blue-pod-restored](/assets/images/blue-green-aks/blue-pod-restored.webp)

## Summary

<!-- TODO: write summary -->