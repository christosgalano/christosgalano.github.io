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

As cloud environments grow, **manual governance stops working**. Different teams implement security differently, configurations drift from standards, and compliance violations only surface after deployment.

Policy-driven governance changes this reactive approach into **proactive enforcement**. By treating policies as code (version-controlled, tested, and automatically enforced) you catch issues during development instead of in production. Resources meet your standards from the start, not as an afterthought.

> The contents of this article are also available as a [YouTube presentation](https://youtu.be/kU1KhvxRynQ?si=f92k4mEnC4bA_y1R).
>
> To explore the concepts hands-on, use the [OPA template repository](https://github.com/christosgalano/opa-template-repo). It ships with ready-to-use policies, tests, CI workflows, bundle publishing, and GitHub Copilot resources for AI-assisted policy authoring.

## The problem with manual governance

**Misconfigurations increase with scale.** That overly permissive security group or unencrypted storage bucket slips through manual reviews. When managing hundreds of resources across multiple teams, human oversight alone isn't enough.

**Security standards fragment.** Without enforced guidelines, each team develops their own interpretation of "secure." Some teams encrypt everything, others might miss critical resources. Some lock down networks tightly, others leave gaps. These inconsistencies create vulnerabilities.

**Resource management becomes difficult.** Teams create resources across regions without coordination, use inconsistent naming conventions, and apply tags haphazardly. This makes cost tracking, resource discovery, and maintenance increasingly complex.

**Governance that depends on human review does not scale.** Most organizations do not lack standards. They lack a consistent and repeatable way to enforce them across fast-moving infrastructure changes.

## How policy as code helps

Policy-driven governance **automates compliance checking**. Instead of relying on manual reviews and hoping teams follow standards, rules execute automatically and consistently.

When policies exist as code, they integrate directly into your deployment workflow. **Governance becomes part of development** rather than a checkpoint at the end. Teams receive immediate feedback about compliance issues while they're still writing infrastructure code.

This approach fundamentally changes when you find problems: during development when fixes are simple, not after deployment when they're expensive and risky.

Good governance should:

- Discover issues before deployment instead of after an incident or audit
- Fit naturally into delivery workflows without becoming a bottleneck
- Apply the same standards across teams, tools, and environments
- Reduce risk without slowing delivery to a halt

## Understanding Open Policy Agent

**Open Policy Agent (OPA)** is a general-purpose, vendor-neutral policy engine. It evaluates structured input (typically JSON) against policies written in Rego. The same engine can support infrastructure, platform, and application governance across clouds, tools, and CI/CD systems.

Created by Styra and now part of the Cloud Native Computing Foundation, OPA has become a standard for policy enforcement in cloud environments. Its key strength is **decoupling policy decisions from application logic**: your systems focus on their core purpose while OPA handles all compliance and authorization decisions.

### How OPA works

OPA follows a straightforward model: **systems ask questions, OPA provides answers**. Each query includes:

- **The request**: "Can this user access this resource?" or "Does this configuration meet our standards?"
- **The context**: User identity, resource metadata, environment details
- **The policies**: Rules written in Rego that define what's allowed

![opa-agent-overview](/assets/images/policy-driven-governance-for-infrastructure-code/open-policy-agent-overview.webp)

OPA's flexibility comes from working with **JSON data**. Since most modern tools can output JSON, OPA can make decisions about virtually anything: Kubernetes configurations, Terraform plans, API requests, or CI/CD pipelines.

![opa-architecture](/assets/images/policy-driven-governance-for-infrastructure-code/opa-architecture.webp)

Unlike vendor-specific policy systems, OPA provides **one consistent approach** across your entire stack. You can also unit-test policies like any other code, ensuring they work correctly before enforcement.

### OPA across multiple control points

OPA is not just a pipeline tool. It can enforce policy at multiple control points:

- **Pre-deployment** in CI/CD to validate infrastructure and configuration changes
- **Deployment-time** in Kubernetes admission control to allow or reject cluster changes
- **Request-time** in proxies and API gateways to enforce authorization and routing guardrails
- **Runtime** in applications and services for policy decisions close to business logic

This makes it possible to apply the same governance model before, during, and after deployment.

## The policy lifecycle

Policy governance is not just about writing rules. It's an operating model:

1. **Define** the guardrails you want teams to follow
2. **Validate** policies before they affect delivery (tests, linting)
3. **Distribute** them in a reusable and consistent way (bundles)
4. **Enforce** them progressively across delivery workflows
5. **Improve** them based on violations, exceptions, and platform change

## Building your governance framework

Effective policy governance starts with a **well-structured policy library**. This becomes your organization's shared understanding of infrastructure standards.

### Organizing policies

A practical structure organizes policies by **tool first, then provider or resource type**:

```text
policy/
├── util/                 # Shared utilities (all tools)
├── terraform/
│   ├── util/             # Tool-specific helpers (tag validation, resource filtering)
│   ├── azuredevops/      # Provider-based grouping
│   │   ├── project/      # Entity policies + tests
│   │   ├── git_repository/
│   │   └── scenarios/    # Combined validations
│   ├── azurerm/
│   └── scenarios/        # Tool-level scenarios
└── arm/
    ├── util/
    ├── resources/        # Direct resource grouping
    └── scenarios/
```

This mirrors how infrastructure teams think: by the tool they use, then by what they're managing. The same pattern extends naturally to Kubernetes (by API group), CloudFormation (by service), or any other tool that produces JSON.

The hierarchy is flexible and tool-specific. Terraform uses a **provider-based hierarchy** (resources grouped by their provider like `azuredevops`, `azurerm`, `aws`). ARM uses a **resource-based hierarchy** without an intermediate provider layer, since ARM templates are Azure-specific. Kubernetes might use **API group-based** grouping (`apps/deployment/`, `networking/ingress/`).

### Package naming conventions

File paths map directly to package names:

| Component | File Pattern | Package Pattern |
|-----------|-------------|-----------------|
| Entity policy | `<entity>.rego` | `<tool>.<org-level>.<entity>` |
| Entity test | `<entity>_test.rego` | `<tool>.<org-level>.<entity>_test` |
| Tool utility | `<function>.rego` | `<tool>.util.<function>` |
| Scenario | `<scenario>.rego` | `<tool>.<org-level>.scenarios.<scenario>` |

For example, a policy at `policy/terraform/azuredevops/git_repository/` has the package `terraform.azuredevops.git_repository`. No magic, just convention.

### Centralization and distribution

**Centralize policy storage** using repositories or registries like Azure Blob Storage, Amazon S3, or container registries. Centralization ensures all teams use the same policies and receive updates immediately.

OPA supports **bundles**: compressed archives (`.tar.gz`) containing Rego policy files, data files, and a manifest with metadata. Bundles enable versioned, centralized policy distribution. Instead of copying Rego files manually, consumers download versioned bundles that include all required dependencies.

Bundles can be full (all policies) or partial (a specific tool/provider subset with its utility dependencies automatically included). This allows teams to download only what they need while keeping bundles self-contained.

**Integrate with CI/CD pipelines** to make policy checks mandatory. No infrastructure changes should deploy without passing governance checks.

## A practical implementation

### Architecture overview

The policy library is maintained independently, published as reusable bundles, and consumed by delivery pipelines that validate infrastructure before deployment:

![architecture](/assets/images/policy-driven-governance-for-infrastructure-code/architecture.webp)

### Modular policy structure

Organizing policies by provider and resource type improves maintainability:

![policy-library](/assets/images/policy-driven-governance-for-infrastructure-code/policy-library.webp)

### Building reusable components

Helper functions reduce duplication. Tag validation ensures consistent resource labeling:

```rego
package terraform.util.tags

# Extract tags from resource
_tags(resource) := resource.change.after.tags

# Check if tag exists
has_tag(resource, tag_name) if {
    _tags(resource)[tag_name]
}

# Verify all required tags present
has_all_tags(resource, required_tags) if {
    keys := object.keys(_tags(resource))
    missing := required_tags - keys
    missing == set()
}
```

![helper-tags](/assets/images/policy-driven-governance-for-infrastructure-code/helper-tags.webp)

Resource filtering allows policies to target specific types and operations:

```rego
package terraform.util.resources

# Return all resources of a given type from the Terraform plan
by_type(type, resources) := [r | some r in resources; r.type == type]
```

![helper-resources](/assets/images/policy-driven-governance-for-infrastructure-code/helper-resources.webp)

### Writing entity policies

Each entity policy follows a consistent structure. Here's an Azure DevOps Git repository validation:

```rego
# METADATA
# scope: package
# description: A set of rules to enforce constraints on Azure DevOps Git repositories.
# entrypoint: true
package terraform.azuredevops.git_repository

import data.terraform.util.resources
import input as tfplan

# METADATA
# title: Deny the creation of Azure DevOps repositories with invalid names.
# description: Azure DevOps repository names must be between 4 and 64 characters long, start with a letter, contain only letters, numbers, or hyphens, and not end with a hyphen.
deny contains msg if {
    repositories := resources.by_type("azuredevops_git_repository", tfplan.resource_changes)
    some repository in repositories
    not has_valid_name(repository.change.after.name)
    annotation := rego.metadata.rule()
    msg := annotation.description
}

has_valid_name(name) if {
    regex.match(`^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$`, name)
    count(name) >= 4
    count(name) <= 64
}
```

Three things to notice:

1. The package-level metadata block with `entrypoint: true` tells OPA and Conftest this is an evaluation entry point
2. Every `deny` rule has its own metadata block. The `description` field IS the error message the user sees, pulled at runtime via `rego.metadata.rule()`
3. The pattern is always the same: filter resources, check a condition, grab the message, emit it. One constraint per rule

![repository](/assets/images/policy-driven-governance-for-infrastructure-code/repository.webp)

### Testing policies

Every policy has a test file right next to it. Tests use factory functions to build variations without repeating themselves:

```rego
package terraform.azuredevops.git_repository_test

import data.terraform.azuredevops.git_repository as repo

valid_repository := {
    "type": "azuredevops_git_repository",
    "change": {"after": {"name": "Valid-Repository-Name"}},
}

repository_with_name(name) := object.union(valid_repository, {"change": {"after": {"name": name}}})
input_with_name(name) := {"resource_changes": [repository_with_name(name)]}

# Baseline: valid configuration must always pass
test_valid_repository_baseline if {
    count(repo.deny) == 0 with input as {"resource_changes": [valid_repository]}
}

test_repository_name_starts_with_number if {
    count(repo.deny) > 0 with input as input_with_name("1invalid-repo")
}

test_repository_name_ends_with_hyphen if {
    count(repo.deny) > 0 with input as input_with_name("invalid-repo-")
}

# Message validation
test_name_deny_message if {
    expected_msg := "Azure DevOps repository names must be between 4 and 64 characters long, start with a letter, contain only letters, numbers, or hyphens, and not end with a hyphen."
    expected_msg in repo.deny with input as input_with_name("invalid () repository")
}
```

![repository-test](/assets/images/policy-driven-governance-for-infrastructure-code/repository-test.webp)

Running tests is straightforward:

```sh
# Test everything
opa test --verbose policy/

# Test specific tool (includes tool utilities automatically)
opa test --verbose policy/terraform/

# Test specific subset (must include dependencies)
opa test --verbose policy/terraform/util/ policy/terraform/azuredevops/
```

### Scenarios: combining policies

Scenarios combine multiple entity validations for end-to-end testing. They re-export deny rules from individual policies and add cross-entity validations:

```rego
# METADATA
# scope: package
# description: Validates a complete Azure DevOps project with repository and settings.
# entrypoint: true
package terraform.azuredevops.scenarios.complete_project

import data.terraform.azuredevops.git_repository
import data.terraform.azuredevops.project

# Re-export all deny rules from included policies
deny := git_repository.deny | project.deny

# METADATA
# title: Ensure project has at least one repository.
# description: Azure DevOps projects must contain at least one Git repository.
deny contains msg if {
    projects := [r | some r in input.resource_changes; r.type == "azuredevops_project"]
    repos := [r | some r in input.resource_changes; r.type == "azuredevops_git_repository"]
    count(projects) > 0
    count(repos) == 0
    annotation := rego.metadata.rule()
    msg := annotation.description
}
```

This validates not just individual resources but relationships between them.

### Enforcing with Conftest

**Conftest** is the practical bridge into delivery workflows. It validates structured data (Terraform plans, Kubernetes manifests, Dockerfiles) against your OPA policies:

```sh
conftest test --policy policy/terraform/ --all-namespaces tfplan.json
```

Violations are reported with the exact message from your policy metadata, making it clear what failed and why:

```
FAIL - tfplan.json - terraform.azuredevops.project - Azure DevOps projects must have private visibility.
FAIL - tfplan.json - terraform.azuredevops.project - Azure DevOps projects must use Git for version control.

3 tests, 1 passed, 0 warnings, 2 failures
```

![conftest](/assets/images/policy-driven-governance-for-infrastructure-code/conftest.webp)

If this ran in CI, the PR would be blocked with these exact messages. Precise, actionable, caught before anything is deployed.

## CI/CD integration

The template repository includes two GitHub Actions workflows:

### CI workflow

Validates all policies on every change:

1. **Lint** with Regal (catches common mistakes and enforces style)
2. **Test** the full suite with OPA
3. **Coverage** enforcement (threshold: 90%+)
4. **Report** results as PR comments

### Bundle publishing workflow

Creates and uploads OPA policy bundles to Azure Blob Storage:

1. Validates policies via CI
2. Resolves dependencies (root utilities + tool utilities)
3. Builds a `bundle.tar.gz` with OPA
4. Uploads to Azure Blob Storage with metadata (Git SHA, path, timestamp)

Authentication uses OpenID Connect (OIDC) workload identity federation. No service principal secrets stored.

## Rolling out policies safely

The safest adoption path is **progressive enforcement**:

1. **Report-only**: Observe baseline, no impact on deployments
2. **Advisory**: CI feedback appears, but nothing is blocked
3. **Soft enforce**: High-value, mature policies begin blocking
4. **Hard enforce**: All proven policies are enforced

Visibility comes first, then confidence, then control. Support justified exceptions through a clear waiver process.

## AI-assisted policy authoring

The template repository ships with GitHub Copilot customization resources that help you author, test, and review policies faster:

```text
.github/
├── copilot-instructions.md          # Global context for every conversation
├── instructions/
│   ├── rego.instructions.md         # Coding standards for .rego files
│   └── rego-test.instructions.md    # Coding standards for _test.rego files
├── prompts/
│   ├── create-policy.prompt.md      # Scaffold a new policy + test pair
│   └── review-policies.prompt.md    # Review, lint, and audit policies
└── agents/
    └── opa-expert.agent.md          # OPA specialist persona
```

The **global instructions** are loaded into every Copilot chat session automatically. The **file-type instructions** apply coding standards when editing `.rego` or `_test.rego` files. This means inline completions and edits follow the repository's conventions without you needing to repeat them.

The **prompt files** are on-demand workflows:

- `/create-policy`: Gathers requirements, computes the correct directory path and package name, scaffolds both the policy and test file following all conventions, then runs `opa test` and `regal lint`
- `/review-policies`: Reads all files in the specified scope, runs linting and testing, checks against structural checklists, analyses cohesion, and produces a structured report

The **OPA Expert agent** is a persistent custom agent for sustained development sessions. It understands the full repository structure, conventions, and toolchain. After authoring policies it can hand off directly into a review session.

Fork the template and your AI assistant already knows your house style from day one.

## Good practices

**Keep policies focused**

- Each policy should address one specific concern (Single Responsibility Principle)
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
- Aim for 100% code coverage
- Use a linter like [Regal](https://github.com/StyraInc/regal) to enforce style and catch common mistakes automatically

**Use pre-commit hooks**

- Run `regal lint` on every commit to catch issues locally before they reach CI
- Complements the AI-assisted workflow

**Plan for scale**

- Use efficient data structures for large rule sets
- Cache external data when possible
- Monitor performance and optimize as needed

**Review regularly**

- Schedule periodic policy reviews
- Remove rules that no longer apply
- Add new policies as requirements evolve

## Expanding beyond basics

Policy governance can handle complex scenarios beyond basic validation:

- **Enforce naming, tagging, and ownership standards** across resources
- **Require different controls** depending on environment, workload, or sensitivity
- **Validate relationships** between resources, not just individual resource settings
- **Encode organization-specific business rules** that generic scanners cannot express cleanly
- **Control costs** by limiting expensive resources
- **Ensure compliance** with data residency and privacy regulations

Once you have OPA in place, the same framework works for application configurations, API authorization, and database access controls. Any tool that produces structured data, OPA can usually evaluate.

## Real-world results

Organizations using policy-driven governance report significant improvements: **fewer security incidents** because issues are caught early, and **faster deployments** because teams work confidently within clear boundaries.

**Platform independence** protects your investment. Policies written for today's Terraform work with tomorrow's infrastructure tools. One policy language serves all your needs.

**Unified enforcement** reduces complexity. Instead of learning multiple vendor-specific policy systems, teams master one approach that works everywhere.

The shift is profound: governance stops being the department that says "no" and becomes the framework that enables "yes, safely." When every deployment automatically meets your standards, teams move faster, not slower. When compliance is built-in, not bolted-on, innovation accelerates.

*Governance isn't a bottleneck. Done right, it doesn't slow teams down; it gives them the confidence to move fast without breaking things.*

## Resources

- [**OPA Template Repository**](https://github.com/christosgalano/opa-template-repo): template with policies, tests, CI, bundles, and GitHub Copilot AI resources
- [**Video Walkthrough**](https://youtu.be/kU1KhvxRynQ?si=f92k4mEnC4bA_y1R)
- [**Open Policy Agent Documentation**](https://www.openpolicyagent.org/docs/latest/)
- [**OPA Playground**](https://play.openpolicyagent.org/)
- [**Conftest**](https://www.conftest.dev/)
- [**Regal**](https://github.com/StyraInc/regal)
