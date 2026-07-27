---
title: "Terraform Stacks: The End of Workspace Sprawl?"
excerpt: "Terraform Stacks are generally available, replacing the root-module-per-environment pattern with components and deployments. What they solve, how the configuration looks, and where the catch is."
tagline: "Environments should be data, not copies of code"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/terraform-stacks/terraform-stacks.webp
tags:
  - iac
  - azure
---

## Overview

Every Terraform estate beyond a certain size converges on the same shape. A root module per environment, or a root module per component per environment. Directories called `prod` and `dev` that are 95 percent identical. A workspace for each, wired to pipelines that must run in an order everyone knows and no tool enforces: networking first, then the platform layer, then the workloads. Multiply by regions and you get the estate nobody admits to owning.

I have spoken about scaling Terraform configurations at conferences, and the honest core of that talk was a set of coping strategies for exactly this. Workspaces, wrapper modules, naming conventions, pipeline choreography. They work. They are also scaffolding around a missing language feature: Terraform had no native way to say "these pieces form one system, deployed many times."

Terraform Stacks, now generally available in HCP Terraform, are HashiCorp's answer. They replace the traditional root module structure with two new concepts: components and deployments. The design is worth understanding even if you never adopt it, because it states plainly what the community has been hand-rolling for a decade.

## Components: the system, described once

A Stack's structure lives in `.tfcomponent.hcl` files. Each `component` block wraps a Terraform module, passes it inputs, and assigns it providers:

{% highlight text %}
{% raw %}
component "network" {
  source = "./modules/network"
  inputs = {
    location      = var.location
    address_space = var.address_space
  }
  providers = {
    azurerm = provider.azurerm.this
  }
}

component "platform" {
  source = "./modules/platform"
  inputs = {
    location  = var.location
    subnet_id = component.network.subnet_id
  }
  providers = {
    azurerm = provider.azurerm.this
  }
}
{% endraw %}
{% endhighlight %}

Two things deserve attention. First, components reference each other directly: `component.network.subnet_id` flows into the platform component, and the dependency ordering falls out of the reference graph. The deployment order you used to encode in pipeline YAML and tribal knowledge is now just data flow.

Second, your existing modules survive unchanged. A component is a wrapper around a plain Terraform module, so the investment in module libraries carries over. Stacks reorganize the layer above modules, the layer that was never really designed, only accreted.

## Deployments: the environments, declared as data

The second file type, `.tfdeploy.hcl`, declares how many times the system exists:

{% highlight text %}
{% raw %}
deployment "dev" {
  inputs = {
    location      = "swedencentral"
    address_space = "10.10.0.0/16"
  }
}

deployment "prod" {
  inputs = {
    location      = "swedencentral"
    address_space = "10.20.0.0/16"
  }
  deployment_group = "deployment_group.production"
}
{% endraw %}
{% endhighlight %}

This is the part that should make the `prod/` and `dev/` directory copies feel obsolete. An environment is no longer a copy of code with different tfvars; it is a block of inputs. Adding a region means adding a deployment block, not cloning a directory tree and hoping the copies never drift.

Deployment groups layer orchestration on top: shared settings and auto-approval rules per group, so dev can roll forward automatically while production waits for a human. The choreography that lived in pipeline configuration moves into the Stack, where it is versioned next to what it orchestrates.

Authentication follows the same declarative pattern. An `identity_token` block mints an OIDC token per deployment, which Azure trusts through workload identity federation:

{% highlight text %}
{% raw %}
identity_token "azurerm" {
  audience = ["api://AzureADTokenExchange"]
}
{% endraw %}
{% endhighlight %}

Each deployment exchanges `identity_token.azurerm.jwt` for its own credentials. No shared service principal secrets smeared across environments, and dev's identity cannot touch prod's subscription.

## What it replaces, and what it does not

The mental model shift is compact. Modules answer "how do I avoid repeating resource definitions?" Workspaces answer "how do I keep state files apart?" Neither answers "what is the system, and how many of it exist?" That is the question Stacks claim, with real capacity behind the claim: a single Stack scales to 100 components and 500 deployments.

Stacks coexist with workspaces in the same HCP Terraform project, so this is not a migration ultimatum. Greenfield systems with many instances are the natural first candidates. A stable estate with three workspaces and no ordering pain has no problem for Stacks to solve, and restructuring it would be motion, not progress.

## The catch

Now the part the announcement posts underplay. Stacks are an HCP Terraform feature. Not a CLI feature you can run anywhere, not part of the BSL-licensed open core, and OpenTofu has no equivalent today. The configuration language is open enough to read, but the orchestration engine that makes it mean something lives in HashiCorp's platform.

That changes the adoption calculus. Adopting modules was a code decision. Adopting Stacks is a platform commitment: your environment topology, orchestration rules, and deployment identities all become artifacts of a commercial service. Perfectly reasonable if you are on HCP Terraform anyway. A real strategic bet if you were keeping your options open, especially with the Terraform and OpenTofu paths diverging as sharply as they have.

Is the trade worth it? It depends on how much workspace sprawl currently costs you, and on how you feel about the vendor question. For a platform team running forty near-identical deployments through hand-choreographed pipelines, Stacks attack a genuine, expensive problem at the right layer: the language. For everyone else, the concepts are still worth learning. Components and deployments name real things, and naming them well is half of architecture.

## Summary

Terraform Stacks replace the improvised root-module-per-environment layer with a declared one: components describe the system and its internal dependencies once, deployments stamp it out per environment as pure data, and deployment groups plus per-deployment OIDC identities absorb the orchestration and authentication choreography that pipelines used to carry. Generally available now, capped generously, and tied to HCP Terraform, which is both the point and the price.

## Resources

- [**Stacks overview**](https://developer.hashicorp.com/terraform/language/stacks)
- [**Stack configuration files**](https://developer.hashicorp.com/terraform/language/files/stack)
- [**Component block reference**](https://developer.hashicorp.com/terraform/language/block/stack/tfcomponent/component)
- [**Deployment block reference**](https://developer.hashicorp.com/terraform/language/block/stack/tfdeploy/deployment)
- [**Terraform Stacks, explained**](https://www.hashicorp.com/en/blog/terraform-stacks-explained)
