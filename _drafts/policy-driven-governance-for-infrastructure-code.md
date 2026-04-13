---
title: "Policy-Driven Governance for Infrastructure Code"
excerpt: "Automate infrastructure compliance and security with policy as code. Learn how Open Policy Agent enables proactive governance that scales across teams and environments."
tagline: "Governance that scales with your infrastructure"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/policy-driven-governance-for-infrastructure-code/opa.webp
tags:
  - iac
  - governance
  - security
---

## Overview

As cloud environments grow, **manual governance stops working**. Different teams implement security differently, configurations slowly drift from standards, and compliance violations only surface after deployment.

Policy-driven governance changes this reactive approach into **proactive enforcement**. By treating policies as code—version-controlled, tested, and automatically enforced—you catch issues during development instead of in production. Resources meet your standards from the start, not as an afterthought.

> The contents of this article are also available as a [YouTube presentation](https://youtu.be/kU1KhvxRynQ?si=f92k4mEnC4bA_y1R).
>
> To explore the concepts hands-on, use the [OPA template repository](https://github.com/christosgalano/opa-template-repo). It ships with ready-to-use policies, tests, CI workflows, and GitHub Copilot resources for AI-assisted policy authoring.

## The problem with manual governance

**Misconfigurations increase with scale**. That overly permissive security group or unencrypted storage bucket slips through manual reviews. When managing hundreds of resources across multiple teams, human oversight alone isn't enough.

**Security standards fragment**. Without enforced guidelines, each team develops their own interpretation of "secure." Some teams encrypt everything, others might miss critical resources. Some lock down networks tightly, others leave gaps. These inconsistencies create vulnerabilities.

**Resource management becomes difficult**. Teams create resources across regions without coordination, use inconsistent naming conventions, and apply tags haphazardly. This makes cost tracking, resource discovery, and maintenance increasingly complex.

## How policy as code helps

Policy-driven governance **automates compliance checking**. Instead of relying on manual reviews and hoping teams follow standards, rules execute automatically and consistently.

When policies exist as code, they integrate directly into your deployment workflow. **Governance becomes part of development** rather than a checkpoint at the end. Teams receive immediate feedback about compliance issues while they're still writing infrastructure code.

This approach fundamentally changes when you find problems: during development when fixes are simple, not after deployment when they're expensive and risky.

## Understanding Open Policy Agent

**Open Policy Agent (OPA)** is a general-purpose decision engine for your infrastructure. It evaluates whether resources, configurations, and changes comply with your organization's rules.

Created by Styra and now part of the Cloud Native Computing Foundation, OPA has become a standard for policy enforcement in cloud environments. Its key strength is **decoupling policy decisions from application logic**: your systems focus on their core purpose while OPA handles all compliance and authorization decisions.

### How OPA works

OPA follows a straightforward model: **systems ask questions, OPA provides answers**. Each query includes:

- **The request**: "Can this user access this resource?" or "Does this configuration meet our standards?"
- **The context**: User identity, resource metadata, environment details
- **The policies**: Rules written in Rego that define what's allowed

![opa-agent-overview](/assets/images/policy-driven-governance-for-infrastructure-code/open-policy-agent-overview.webp)

OPA's flexibility comes from working with **JSON data**. Since most modern tools can output JSON, OPA can make decisions about virtually anything—Kubernetes configurations, Terraform plans, API requests, or CI/CD pipelines.

![opa-architecture](/assets/images/policy-driven-governance-for-infrastructure-code/opa-architecture.webp)

Unlike vendor-specific policy systems, OPA provides **one consistent approach** across your entire stack. You can also unit-test policies like any other code, ensuring they work correctly before enforcement.

## Building your governance framework

Effective policy governance starts with a **well-structured policy library**. This becomes your organization's shared understanding of infrastructure standards.

### Organizing policies

A practical structure organizes policies by **tool first, then provider or resource type**:

```text
policy/
├── terraform/
│   ├── util/             # shared helpers (tag validation, resource filtering)
│   ├── azuredevops/      # rules per resource type
│   ├── azurerm/
│   └── scenarios/        # multi-resource validations
└── arm/
    ├── resources/
    └── scenarios/
```

This mirrors how infrastructure teams think: by the tool they use, then by what they're managing. The same pattern extends naturally to Kubernetes (by API group), CloudFormation (by service), or any other tool that produces JSON.

**Centralize policy storage** using repositories or registries like Azure Blob Storage, Amazon S3, or container registries. Centralization ensures all teams use the same policies and receive updates immediately.

**Integrate with CI/CD pipelines** to make policy checks mandatory. No infrastructure changes should deploy without passing governance checks.

## A practical implementation

### Architecture overview

![architecture](/assets/images/policy-driven-governance-for-infrastructure-code/architecture.webp)

### Modular policy structure

Organizing policies by provider and resource type improves maintainability:

![policy-library](/assets/images/policy-driven-governance-for-infrastructure-code/policy-library.webp)

### Building reusable components

Helper functions reduce duplication. Tag validation ensures consistent resource labeling:

```rego
# Check all required tags are present on a resource
has_all_tags(resource, required_tags) if {
    keys    := object.keys(resource.change.after.tags)
    missing := required_tags - keys
    missing == set()
}
```

![helper-tags](/assets/images/policy-driven-governance-for-infrastructure-code/helper-tags.webp)

Resource filtering allows policies to target specific types and operations:

```rego
# Return all resources of a given type from the Terraform plan
by_type(type, resources) := [r | some r in resources; r.type == type]
```

![helper-resources](/assets/images/policy-driven-governance-for-infrastructure-code/helper-resources.webp)

### Policy examples

Each resource type needs specific rules. Repository policies might enforce naming conventions and security configurations:

![repository](/assets/images/policy-driven-governance-for-infrastructure-code/repository.webp)

Every policy needs tests to verify correct behavior:

![repository-test](/assets/images/policy-driven-governance-for-infrastructure-code/repository-test.webp)

### Testing with Conftest

**Conftest** simplifies policy testing for developers. It validates structured data—Terraform plans, Kubernetes manifests, Dockerfiles—against your OPA policies. Run it locally before pushing, or integrate it as a CI step:

```sh
# Validate a Terraform plan against your policies
conftest test --policy policy/ --all-namespaces tfplan.json
```

Violations are reported with the exact message from your policy metadata, making it clear what failed and why:

```
FAIL - tfplan.json - terraform.azuredevops.project - Azure DevOps projects must have private visibility.
FAIL - tfplan.json - terraform.azuredevops.project - Azure DevOps projects must use Git for version control.
```

![conftest](/assets/images/policy-driven-governance-for-infrastructure-code/conftest.webp)

## Good practices

**Keep policies focused**
- Each policy should address one specific concern
- Simplifies debugging when policies fail
- Allows teams to use only what they need

**Create reusable components**
- Build shared functions for common patterns
- Maintain consistency across policies
- Update in one place, benefit everywhere

**Test thoroughly**
- Write tests for both passing and failing scenarios
- Cover edge cases before they appear in production
- Treat policy tests like application tests
- Use a linter like [Regal](https://github.com/StyraInc/regal) to enforce style and catch common mistakes automatically

**Plan for scale**
- Use efficient data structures for large rule sets
- Cache external data when possible
- Monitor performance and optimize as needed

**Track and measure**
- Log policy violations to identify patterns
- Monitor evaluation performance
- Use metrics to improve policies over time

**Review regularly**
- Schedule periodic policy reviews
- Remove rules that no longer apply
- Add new policies as requirements evolve

## Expanding beyond basics

Policy governance can handle complex scenarios beyond basic validation.

- **Assess change impact** before deployment
- **Control costs** by limiting expensive resources
- **Ensure compliance** with data residency and privacy regulations

Once you have OPA in place, the same framework works for application configurations, API authorization, and database access controls—any structured data your organization manages.

## Real-world results

Organizations using policy-driven governance report significant improvements: **fewer security incidents** because issues are caught early, and **faster deployments** because teams work confidently within clear boundaries.

**Platform independence** protects your investment. Policies written for today's Terraform work with tomorrow's infrastructure tools. One policy language serves all your needs.

**Unified enforcement** reduces complexity. Instead of learning multiple vendor-specific policy systems, teams master one approach that works everywhere.

The shift is profound: governance stops being the department that says "no" and becomes the framework that enables "yes, safely." When every deployment automatically meets your standards, teams move faster, not slower. When compliance is built-in, not bolted-on, innovation accelerates.

*Governance isn't a bottleneck—it's an enabler. Done right, it doesn't slow teams down; it gives teams the confidence to move fast without breaking things.*

## Resources

- [OPA Template Repository](https://github.com/christosgalano/opa-template-repo) — template with policies, tests, CI, and GitHub Copilot AI resources
- [Video Walkthrough](https://youtu.be/kU1KhvxRynQ?si=f92k4mEnC4bA_y1R)
- [Open Policy Agent Documentation](https://www.openpolicyagent.org/docs/latest/)
- [OPA Playground](https://play.openpolicyagent.org/)
- [Conftest](https://www.conftest.dev/)
- [Regal — Rego Linter](https://github.com/StyraInc/regal)
