---
title: "Bicep Learns to Look Around: The this Namespace"
excerpt: "Bicep templates have always been blind to the environment they deploy into. The experimental this.exists() and this.existingResource() functions change that, letting a resource adapt its configuration to what is already running."
tagline: "A template that can see is a template that can decide"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/bicep-this-namespace/bicep-this-namespace.webp
tags:
  - azure
  - iac
---

## Overview

Bicep has a blind spot, and if you have operated it long enough, you have met it. A template describes desired state, but it cannot ask the most natural question in the world: does this resource already exist, and what does it look like right now?

That question comes up constantly. You want to preserve a setting that operators tune in production. You want a different configuration on first deployment than on every subsequent one. You want to avoid resetting something a template redeploy has no business touching. Until recently, Bicep's answer was: not your concern, declare the end state and hope.

The experimental `this` namespace, introduced in Bicep v0.40.2, gives templates deployment-time sight. Two functions, `this.exists()` and `this.existingResource()`, let a resource inspect its own current state in Azure while the deployment runs. Small surface, big consequences. Everything in this post was compiled and tested with Bicep CLI 0.45.15.

## The problem, concretely

Take the classic case: a storage account whose `accessTier` the operations team changes based on usage patterns. Your template says `Hot`, because that was right on day one. Six months later, someone flips production to `Cool` for cost reasons. The next pipeline run redeploys the template, and quietly flips it back.

Nothing failed. That is what makes it nasty. The deployment succeeded, the template is "correct", and the cost optimization is gone until someone notices the bill.

The traditional workarounds all hurt in different ways:

- **Parameterize it** and you push the problem to whoever maintains the parameter files, who now must mirror reality by hand.
- **An `existing` reference** to the same resource you are deploying is circular and does not work.
- **Deployment scripts** that read current state before the deployment work, but now you maintain PowerShell glue, an identity for it, and cleanup logic for what should have been one expression.

What you actually want to write is: keep the current tier if the resource exists, otherwise start with `Hot`. That is now a sentence Bicep can express.

## The two functions

Inside a resource definition, `this` refers to the resource being declared. Two calls are available:

- `this.exists()` returns a `bool`: whether the resource currently exists in Azure.
- `this.existingResource()` returns the resource's current object if it exists, `null` otherwise.

Both are evaluated during deployment, by ARM, against the live environment. This is the crucial difference from everything else in the language: template compilation stays offline, but these expressions resolve at deployment time against actual state.

The naive version of our storage account looks like this:

{% highlight text %}
{% raw %}
resource sa 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stexample001'
  location: 'swedencentral'
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    accessTier: this.exists() ? this.existingResource().properties.accessTier : 'Hot'
  }
}
{% endraw %}
{% endhighlight %}

Readable, but compile it and Bicep raises `BCP318`: the value of `this.existingResource()` is typed as possibly null, and the compiler does not treat the ternary as a guard. The warning is fair. The idiomatic fix is the safe-dereference operator with a coalesce, which also happens to be shorter:

{% highlight text %}
{% raw %}
properties: {
  accessTier: this.existingResource().?properties.accessTier ?? 'Hot'
}
{% endraw %}
{% endhighlight %}

This compiles clean. Peek at the generated ARM and you can see exactly what the runtime will do:

{% highlight json %}
{% raw %}
"accessTier": "[coalesce(tryGet(target('full'), 'properties', 'accessTier'), 'Hot')]"
{% endraw %}
{% endhighlight %}

A `tryGet` against `target('full')`, the deployment-time representation of the resource itself, wrapped in a `coalesce` for the first-deployment case. No scripts, no parameters, no circular references. The template now reads as the policy it always wanted to be: existing tier wins, `Hot` is the default for newcomers.

## Where this pattern earns its keep

Once you see the shape, candidates appear everywhere:

- **Operator-tuned settings**: capacity, tiers, autoscale bounds. Anything a human adjusts in response to reality and a redeploy should respect.
- **First-deployment-only values**: seed a configuration on creation, never touch it again.
- **Conditional wiring**: skip an expensive sub-resource when the parent already carries one, without threading `newOrExisting` parameters through three module layers. If you have ever maintained one of those parameters, you know it is a lie waiting to age.

There is also a philosophical shift hiding here, worth naming. Pure declarative doctrine says the template is the truth and the environment must converge to it. The `this` namespace admits what operators always knew: some truth lives in the environment, and a good template negotiates with it instead of steamrolling it. Purists will wince. Practitioners will ship.

## The caveats, honestly

This is an experimental feature, and the tooling does not let you forget it.

First, depending on your Bicep version you must opt in through `bicepconfig.json`:

{% highlight json %}
{% raw %}
{
  "experimentalFeaturesEnabled": {
    "thisNamespace": true
  }
}
{% endraw %}
{% endhighlight %}

Second, and more importantly, compiling a template that uses `this` stamps the output with `"languageVersion": "2.1-experimental"` and an explicit warning that experimental ARM features carry no stability guarantees. That marker is your answer to "can I use this in production": not yet, not for anything that matters. Syntax can change, behavior can change, and Microsoft says so in the generated artifact itself.

Third, think about what deployment-time state inspection does to reviewability. A classic template's effect can be reasoned about from the diff. A `this`-aware template's effect depends on the environment at the moment of deployment, which means the same template can do different things in different subscriptions. That is the feature working as intended, and it is also one more reason your what-if checks and post-deployment validations matter more, not less.

Should you adopt it today? For experiments and non-critical environments, absolutely: this is the best time to learn the pattern and to file feedback while the design is still movable. For production, wait for the flag to disappear and the language version to lose its suffix.

## Summary

The `this` namespace gives Bicep resources deployment-time awareness of their own current state: `this.exists()` answers whether the resource is there, `this.existingResource()` hands you its live configuration, and the safe-dereference-plus-coalesce pattern turns both into clean "preserve or default" expressions. It closes a gap that previously demanded deployment scripts or parameter gymnastics, at the price of templates whose behavior depends on the environment they meet. Experimental for now, worth watching closely, and worth playing with today.

## Resources

- [**Bicep resource functions**](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-resource)
- [**Bicep v0.40.2 release notes**](https://github.com/Azure/bicep/releases/tag/v0.40.2)
- [**Bicep experimental features**](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-config)
