---
title: "OpenTofu vs Terraform in 2026: The Fork Grew Up"
excerpt: "Three years after the license change, OpenTofu and Terraform are no longer interchangeable. A look at where each actually invested, and a framework for choosing that does not involve tribal loyalty."
tagline: "Forks are questions; roadmaps are the answers"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/opentofu-vs-terraform/opentofu-vs-terraform.webp
tags:
  - iac
  - architecture
---

## Overview

When HashiCorp moved Terraform to the Business Source License in August 2023 and the community forked it into OpenTofu, the safe prediction was that the fork would either fizzle or trail upstream forever. Neither happened. Three years on, the two projects are not versions of the same tool anymore; they are two tools with a shared ancestor and visibly different ideas about where the value lives.

If you write HCL for a living, you can defer the choice no longer than your next platform decision. So instead of the usual feature-table war, let me lay out what each project actually shipped, what that reveals about their trajectories, and how I would decide today.

## What OpenTofu shipped: the CLI wishlist

OpenTofu's release history reads like the Terraform issue tracker's greatest hits, the requests that sat open for years finally getting implemented:

- **State encryption** (1.7): client-side encryption of state at rest, ending the era of "the state file is plaintext, secure the bucket and pray". For regulated environments this was the headline feature, and it still has no CLI equivalent on the other side. It is also strict in the right way: I tested `enforced = true` against an existing plaintext state, and OpenTofu refuses to touch it until you configure an explicit fallback for the migration. Encryption that cannot be silently skipped is the only kind worth deploying.
- **Early variable evaluation** (1.8): variables and locals usable in places they never could be, like backend configuration and module sources.
- **Provider iteration with `for_each`** (1.9): multi-region deployments without copy-pasting provider blocks, one of the oldest and most upvoted requests in the ecosystem's history.
- **The `-exclude` flag** (1.9): the natural complement to `-target` that somehow never existed.
- **OCI registry support** (1.10): modules and providers pulled from the same artifact registries the rest of your platform already runs.
- **Ephemeral values** (1.11): short-lived secrets that flow through a run without being persisted to state.
- **Dynamic `prevent_destroy`** (1.12): lifecycle guards wired to variables, so production can lock what development leaves open, from one shared module. Anyone maintaining environment-forked modules purely because of hardcoded lifecycle blocks knows exactly how overdue this was. I verified the behavior on v1.12.4: `tofu destroy` fails cleanly with the guard variable set to true, and the error message even points you at `-exclude` to work around individual resources.

The pattern is unmistakable. OpenTofu is investing in the day-to-day ergonomics of the open CLI: the tool you run in CI, the language you write, the state you carry.

## What Terraform shipped: the platform

HashiCorp (now under IBM) has kept the Terraform CLI moving, but the center of gravity of its roadmap is unambiguous: HCP Terraform. The flagship investment is Stacks, the component-and-deployment model for managing many environments as declared data, which I covered in a separate post. Around it sits the broader platform story: Project Infragraph and a deepening integration surface across the HashiCorp portfolio.

The pattern here is just as unmistakable. Terraform's differentiation is being built where the license protects it: in the hosted platform, the orchestration layer, the enterprise workflow. The CLI remains solid and maintained, but it is the on-ramp, not the destination.

Neither strategy is wrong. They are answers to different questions. OpenTofu asks "what should the tool be?" HashiCorp asks "what should the product be?"

## The gap is now structural

Early on, staying compatible with both was trivial; the projects were near-identical. That window has closed. State encryption changes what a state file is. Early evaluation changes what valid configuration is. Provider iteration changes how modules get structured. Stacks change how environments are organized. Code written idiomatically for one increasingly will not run, or will not make sense, under the other.

This is the fact that should anchor your decision: you are not picking a binary, you are picking a dialect and a roadmap. Migration in either direction is still feasible today, and gets a little less trivial with every release on both sides.

## How I would decide

Four questions, in order of weight:

**Are you invested in HCP Terraform, or want to be?** If Stacks, the registry, run orchestration, and the governance features solve expensive problems for you, the decision is made: Terraform. Building on the platform while running the fork's CLI is fighting your own tooling.

**Do you have hard requirements the fork uniquely meets?** State encryption for compliance, OCI-based distribution to match your artifact strategy, air-gapped registries. If these are requirements rather than preferences, OpenTofu earns the slot on merit, not ideology.

**How much does license risk actually cost you?** For most internal platform teams, the BSL changes nothing day to day. If you are a vendor embedding the tool, or an organization with strict open-source policies, the calculus is entirely different, and the Linux Foundation home of OpenTofu is the point.

**What does your team already run?** Inertia is a legitimate input. A stable Terraform estate with no platform ambitions and no compliance pressure has no urgent reason to move. Same for a happy OpenTofu shop. Migration should be pulled by a problem, not pushed by a headline.

Notice what is not on the list: fear that either project dies. Both have passed the survival test. OpenTofu ships meaningful releases on a steady cadence under foundation governance; Terraform has IBM-scale backing. The "wait and see which one wins" position made sense in 2024. In 2026 it is just deferred decision-making with none of the benefits.

The hedge worth mentioning is the dual-engine pattern some large organizations have landed on: Terraform where HCP features carry the workflow, OpenTofu for greenfield work where open-source continuity and CLI features matter more. It costs you some consistency, buys you optionality, and works best when module libraries are kept to the compatible core so components can move if they must. Whether that trade makes sense at your scale is, of course, the eternal answer: it depends.

## Summary

The fork grew up, and the projects grew apart. OpenTofu spent three years shipping the CLI features practitioners had requested for a decade: state encryption, provider iteration, early evaluation, dynamic lifecycle guards. Terraform built its moat one layer up, in HCP, with Stacks as the flagship. Choose by platform commitment, hard requirements, license exposure, and inertia, in that order, and choose consciously: the dialects are diverging, and code written today is a vote for one roadmap or the other.

## Resources

- [**OpenTofu**](https://opentofu.org/)
- [**OpenTofu releases**](https://github.com/opentofu/opentofu/releases)
- [**OpenTofu 1.12 coverage (InfoQ)**](https://www.infoq.com/news/2026/05/opentofu-release-terraform/)
- [**Terraform Stacks**](https://developer.hashicorp.com/terraform/language/stacks)
- [**My post on Terraform Stacks**](/terraform-stacks/)
