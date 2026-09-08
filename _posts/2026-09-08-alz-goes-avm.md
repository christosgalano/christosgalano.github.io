---
title: "Your Landing Zone Learned Modularity: ALZ Goes AVM"
excerpt: "Bicep Azure Verified Modules for Platform Landing Zone reached general availability, classic ALZ-Bicep is on its way out, and Deployment Stacks give the whole thing lifecycle memory. What changed and what to do about it."
tagline: "A landing zone is a composition, not a monolith"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/alz-goes-avm/alz-goes-avm.webp
tags:
  - azure
  - iac
  - governance
---

## Overview

If you deployed an Azure landing zone with Bicep in the last few years, you used ALZ-Bicep: the big, capable, and famously opinionated reference implementation. It got thousands of organizations onto a sound management group hierarchy, and it had one recurring complaint threaded through its issue tracker: customization. The moment your organization deviated from the reference, and every organization deviates, you were maintaining a fork of a monolith.

That era is ending. In January 2026, Microsoft made Bicep Azure Verified Modules for Platform Landing Zone generally available, rebuilding the landing zone as a composition of Azure Verified Modules. Classic ALZ-Bicep was removed from the ALZ Accelerator on February 16, 2026, and the repository itself will be archived on February 16, 2027. This is not a version bump. It is an architectural replacement, and it deserves a closer look.

## From monolith to composition

The new approach centers on a starter module composed of 19 Azure Verified Modules: 16 resource modules and 3 pattern modules, covering the deployment areas a platform landing zone actually consists of: the ALZ core (management groups and policies), management resources, and connectivity as either hub networking or Virtual WAN.

The word doing the work in that sentence is *verified*. Azure Verified Modules are Microsoft-maintained, tested, and versioned building blocks with a public support statement, the same modules you would use to build workload infrastructure. The landing zone now consumes them instead of shipping its own parallel resource implementations.

Why does that matter in practice?

- **Customization becomes configuration, not forking.** The old model buried decisions inside a deep template hierarchy; changing them meant patching vendored code and re-patching on every upstream release. The AVM-based starter module was explicitly designed around the customization feedback, down to letting you fully control resource names. Anyone who has fought a reference implementation over a naming convention knows this is not a small thing.
- **One module ecosystem instead of two.** Your platform team and your workload teams now draw from the same catalog, with the same conventions, telemetry, and update cadence. The skills transfer both ways.
- **Versioned building blocks.** When a fix lands in an AVM resource module, you pick it up by bumping a version reference, not by diffing your fork against upstream and hoping.

## Deployment Stacks: the landing zone gets memory

The second architectural choice is quieter but, for operators, maybe more important: the new implementation deploys through Azure Deployment Stacks.

Classic ALZ-Bicep had a well-known operational wart. Standard ARM deployments are additive: they create and update, but they do not remove what your template stopped declaring. Retire a policy assignment from the templates and the assignment happily lives on in Azure until someone deletes it by hand. At landing-zone scale, with hundreds of policy objects, "someone deletes it by hand" is a governance gap with a long tail.

Deployment Stacks close it. A stack tracks the set of resources its template manages, and when a new deployment no longer declares something, the stack can clean it up. Your landing zone repository finally means what it says: what is in the code exists, what leaves the code leaves Azure. Drift between the governance you declare and the governance actually applied stops being a standing assumption.

This pairing, AVM for composition and stacks for lifecycle, is the interesting design signal. Microsoft is converging on landing zones as regular infrastructure code with regular lifecycle semantics, rather than a special artifact deployed once and patched forever.

## What to do, depending on where you stand

**Starting fresh?** Easy call. Use the AVM-based approach through the ALZ Accelerator. Building on classic ALZ-Bicep today means adopting a codebase with a announced end date.

**Running classic ALZ-Bicep?** No need to panic, but the clock is now explicit. The ALZ-Bicep repository remains supported for bug fixes, security patches, and policy refreshes until February 16, 2027, after which it will be archived. That is your migration window, and it is generous exactly once. The path to the AVM-based implementation is the thing to design deliberately: policy assignments, management group structure, and any customizations you carried in your fork need mapping onto the starter module's configuration surface. Microsoft publishes migration guidance at [aka.ms/alz/acc/bicep](https://aka.ms/alz/acc/bicep); treat your fork's divergence from upstream as the measure of the work.

**Heavily customized?** You are, paradoxically, the biggest winner. The organizations that suffered most under the monolith, the ones with renamed everything and restructured hierarchies, are the ones the modular design was built for. Your migration is larger, but your steady state gets dramatically better.

One caution against over-rotating: a landing zone migration is still a governance change at the root of your tenant. The tooling improved; the blast radius did not shrink. Test the new structure in a canary tenant or an isolated management group branch, use what-if output and stack previews, and move policy assignments in stages. Boring, deliberate, correct.

## Summary

The Bicep landing zone story moved from a monolithic reference implementation to a composition of 19 Azure Verified Modules deployed through Deployment Stacks, generally available since January 2026, with classic ALZ-Bicep out of the Accelerator and its repository heading for archive in February 2027. Composition makes customization a supported act instead of a fork, and stacks give governance code real lifecycle semantics, including the removal half that ARM deployments never had. New deployments should start on AVM now; existing estates should size their migration by how far they diverged from the old reference, and execute it like the root-level change it is.

## Resources

- [**Azure Landing Zones: Bicep documentation**](https://azure.github.io/Azure-Landing-Zones/bicep/)
- [**ALZ-Bicep deprecation timeline**](https://github.com/Azure/ALZ-Bicep)
- [**Release announcement (Microsoft Community Hub)**](https://techcommunity.microsoft.com/blog/azuretoolsblog/release-of-bicep-azure-verified-modules-for-platform-landing-zone/4487932)
- [**Azure Verified Modules**](https://azure.github.io/Azure-Verified-Modules/)
- [**Azure Deployment Stacks**](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks)
