---
title: "GitHub Actions Grows a Chain of Custody"
excerpt: "Immutable OIDC subject claims, immutable actions and releases, artifact attestations by default: GitHub is quietly rebuilding the Actions supply chain around one idea, and it will break a federated credential near you."
tagline: "Trust is cheap to grant and expensive to revoke"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/github/actions/github-actions-2.webp
tags:
  - github
  - security
  - ci-cd
---

## Overview

Supply chain security announcements usually arrive one at a time, each reasonable, none urgent. Step back from GitHub's stream of them over the past year and a pattern snaps into focus: immutable subject claims for OIDC tokens, immutable actions, immutable releases, artifact attestations moving toward default-on. Four features, one idea. Every link between your pipeline and the things it trusts is being pinned to something that cannot be renamed, retagged, or quietly replaced.

I have written before about GitHub's security features from the repository side: code scanning, secret scanning, Dependabot. This wave is different. It targets the pipeline itself, and one piece of it, the OIDC change, has a date attached that anyone federating to Azure should read twice: July 15, 2026. Twelve days ago.

## Names lie; IDs do not

Start with the conceptual core, because every feature in this wave inherits it.

Almost everything in the Actions ecosystem has historically been addressed by name: `owner/repo` in your federated credentials, `owner/action@v4` in your workflows, a release tag on a download. Names are human-friendly and mutable, and mutable is the problem. Delete your organization and someone can re-register it. Retag `v4` and every workflow pulling it gets new code. The name still matches; the thing behind it changed. Security people call this a resurrection or repo-jacking attack, and it is not theoretical.

The fix is unglamorous and correct: bind trust to immutable numeric IDs instead of names, and freeze the artifacts the names point to.

## The OIDC change: check your federated credentials

The concrete instance that lands on your desk first. GitHub Actions OIDC tokens carry a `sub` claim that cloud providers match against trust policies; it is the string you typed into your Entra ID federated credential when you set up keyless deployments to Azure:

{% highlight text %}
{% raw %}
repo:octocat/my-repo:ref:refs/heads/main
{% endraw %}
{% endhighlight %}

The new format appends immutable owner and repository IDs:

{% highlight text %}
{% raw %}
repo:octocat@123456/my-repo@456789:ref:refs/heads/main
{% endraw %}
{% endhighlight %}

Now the trust is tied to the repository, the actual database row, not to whatever currently answers to its name. If the organization name is abandoned and re-registered by someone else, their tokens carry different IDs and every trust policy built on the new format correctly rejects them.

The rollout mechanics are where operations teams need to pay attention:

- Repositories created after **July 15, 2026** use the new format automatically.
- Repositories **renamed or transferred** after that date adopt it as well.
- Existing repositories keep the old format unless you opt in through the OIDC settings UI or API, and a preview endpoint shows you the exact new prefix before you commit.
- github.com only; GitHub Enterprise Server is unaffected for now.

Read that second bullet again. A routine repository rename now silently changes the `sub` claim, and your Azure federated credential, which matches the subject string exactly, stops matching. The deployment fails with an authentication error, and nothing in the rename flow warns you. If your organization is mid-restructuring, renaming repositories as teams reshuffle, you have a queue of these waiting.

The sane response: inventory your federated credentials now (in Azure, that is a quick scan of app registrations and managed identities with subjects starting `repo:`), use the preview endpoint to capture new-format subjects, and fold "update the federated credential" into whatever process governs repository renames. Then opt your critical repositories in deliberately, on your schedule, rather than having a rename do it for you on its own.

## Freezing the artifacts: immutable actions and releases

The same principle applied one layer up. Actions have always been consumed by git ref, and the standing advice was to pin by commit SHA because tags can move. Sound advice with a poor adoption rate, because 40-character hashes are hostile to humans. Organization policies can now enforce SHA pinning and block specific actions outright, but enforcement of a workaround is still a workaround.

Immutable actions attack the root: the action is published as a versioned, frozen artifact through the workflow itself, so what you reference is what everyone got, permanently. Immutable releases extend the same guarantee to release assets and their git tags, with attestations to make the integrity verifiable. Retagging, the classic supply chain move where `v3` becomes something else after you audited it, stops being possible against a frozen release.

The endgame is easy to extrapolate: consuming mutable actions will become the flagged exception in security overviews, then the policy violation. Getting your own published actions onto the immutable path early is cheap; being herded onto it later is not.

## Attestations: the artifact carries its birth certificate

The third leg. Artifact attestations bind what you built to how it was built: a signed, verifiable statement that this exact artifact came from this workflow, this commit, this runner. Downstream, `gh attestation verify` or a policy engine in your deployment pipeline can refuse anything that arrives without provenance. For public repositories, attestation generation is moving from opt-in to default behavior.

If you run internal platforms, the interesting move is on the consumption side: a deployment gate that requires valid provenance turns "where did this container come from" from a forensic question into a precondition. Attestation without verification is paperwork; the verify step is where the security lives.

## What to actually do

A short, ordered list, most urgent first:

1. **Inventory OIDC trust.** Every federated credential matching a `repo:` subject, in every cloud. Know which repositories back them.
2. **Wire renames to credential updates.** The July 15 behavior makes rename-breaks-deployment a standing failure mode. Make it a checklist item with an owner.
3. **Opt critical repositories into immutable claims** deliberately, after updating the matching trust policies.
4. **Enforce SHA pinning or blocking policies** for third-party actions today; adopt immutable actions for anything you publish.
5. **Start signing and verifying artifacts** on one critical pipeline, end to end, before rolling wider. The tooling is ready; the discipline is the work.

None of this is glamorous. Supply chain security rarely is. But the direction is set, the defaults are shifting, and the teams that move with the wave get to do it calmly.

## Summary

GitHub is rebuilding Actions trust around immutability: OIDC subject claims pinned to repository IDs (automatic for new and renamed repositories since July 15, 2026), actions and releases published as frozen artifacts, and attestations making provenance a verifiable property rather than a hope. The practical exposure for most teams is the OIDC change, because exact-match federated credentials in Azure and elsewhere break silently on rename. Inventory first, wire renames to credential updates, then adopt the rest of the wave on your own terms.

## Resources

- [**Immutable subject claims for GitHub Actions OIDC tokens**](https://github.blog/changelog/2026-04-23-immutable-subject-claims-for-github-actions-oidc-tokens/)
- [**GitHub Actions security roadmap discussion**](https://github.com/orgs/community/discussions/190621)
- [**Actions policy: blocking and SHA pinning**](https://github.blog/changelog/2025-08-15-github-actions-policy-now-supports-blocking-and-sha-pinning-actions/)
- [**Artifact attestations**](https://github.blog/news-insights/product-news/introducing-artifact-attestations-now-in-public-beta/)
- [**attest-build-provenance action**](https://github.com/actions/attest-build-provenance)
