---
title: "Blue/Green AKS: Part 2 - Usage"
excerpt: "In today’s blog post, we deploy a sample application and test the blue/green capability."
tagline: "Test the blue/green capability"
header:
  overlay_color: "#24292f"
  teaser: assets/images/blue-green-aks/blue-green-deployment.webp
categories:
  - azure
  - kubernetes
tags:
  - aks
  - blue-green
toc: true
related: true
---

## General

Hello everyone! In this post we will deploy a sample application and perform a switch between the two environments.

Of course, before we begin deploying the application we need to set up our infrastructure.

## Infrastructure deployment

You can find the Infrastructure as Code files in the [**bicep**](https://github.com/christosgalano/Blue-Green-AKS/tree/main/bicep) folder and the deployment script in the [**.github/scripts**](https://github.com/christosgalano/Blue-Green-AKS/tree/main/.github/scripts) folder.

In the [**.github/workflows**](https://github.com/christosgalano/Blue-Green-AKS/tree/main/.github/workflows) folder, you can also find 3 workflows:

- **deploy** which is used to deploy the infrastructure
- **destroy** which is used to destroy the infrastructure
- **psrule_scan** which is used to scan our IaC using PSRule

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

{% highlight bash %}
az login --identity
az aks get-credentials --resource-group <aks-rg-name> --name <blue-aks-name>
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
{% endhighlight %}

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

Well, this brings the Blue/Green AKS series to an end. I hope you found the information useful and that it inspires you to experiment with it.

**Previous parts:**

- **Part 0: Introduction**
- **Part 1: Infrastructure**
  
**Related repository:** [Blue-Green-AKS](https://github.com/christosgalano/Blue-Green-AKS)
