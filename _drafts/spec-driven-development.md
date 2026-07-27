---
title: "The Spec Outlives the Session: On Spec-Driven Development"
excerpt: "When agents write the code, the prompt becomes the artifact worth engineering. Spec-driven development turns intent into a reviewable, versioned document, and it is quietly becoming the workflow for AI-assisted teams."
tagline: "Code is the output; intent is the asset"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/spec-driven-development/spec-driven-development.webp
tags:
  - ai
  - architecture
---

## Overview

Here is an uncomfortable observation about AI-assisted development as most teams practice it: the most important artifact of the process is destroyed the moment it succeeds.

You describe the feature to an agent, refine your intent across a dozen conversational turns, correct its misunderstandings, sharpen the edge cases. Then the code lands, the session closes, and everything you clarified evaporates. The code remembers what was built. Nothing remembers what was meant. Three months later, when someone, human or agent, needs to change that code, they reverse-engineer intent from implementation, which is exactly the archaeology we always did, now performed on code nobody wrote.

Vibe coding, as this mode came to be called, is a brilliant way to explore and a terrible way to build things that must survive. Spec-driven development is the correction, and it has matured from blog-post idea to tooled workflow fast: GitHub open-sourced Spec Kit in late 2025, and the approach has become one of the defining development workflows of 2026.

## The inversion

Spec-driven development makes one move, and everything else follows from it: the specification, not the prompt, is the primary artifact. Code becomes its expression.

In the Spec Kit formulation the workflow opens with an optional constitution step (`/speckit.constitution`, the project's governing principles) and then runs through four phases, each producing a Markdown document that feeds the next: **specify** (what to build and why, as `spec.md`), **plan** (the technical approach, as `plan.md`), **tasks** (the decomposition into implementable units, as `tasks.md`), and **implement** (the agent writes the code, guided by all three). Templates, quality checklists, and cross-artifact analysis ship in the box, and the toolkit integrates with the agents people already use: Copilot, Claude, Codex, Gemini, and some thirty others.

The mechanics matter less than what they change. The dozen clarifying turns from the chat session still happen, but their result lands in a document that is versioned, reviewable, and durable. Intent gets the same treatment we give code: history, diffs, an approval trail.

If you have spent years in infrastructure, this rhymes loudly. We did not improve operations by getting better at typing commands into consoles; we improved by declaring desired state in files and letting machinery converge on it. Spec-driven development is declarative infrastructure's argument applied to software intent. The spec is the desired state. The agent is the reconciler.

## What it actually fixes

Three failure modes of prompt-first development, and how the inversion addresses them.

**Review moves to the right altitude.** Reviewing five hundred lines of agent-generated code is a losing game; the volume defeats the reviewer, and plausible-looking code defeats skimming. Reviewing a two-page spec is a winnable one. Disagreements about scope, sequencing, and edge cases surface before implementation, where they cost a comment instead of a rewrite. The senior engineer's attention lands where it discriminates best: on intent and approach, not on whether the agent remembered a null check, which is CI's job anyway.

**Work becomes resumable and parallel.** A spec plus a task list is a contract any agent, or any colleague, can pick up cold. The context that lived in one person's chat history becomes shared state. Agents can work tasks in parallel against one plan; a failed implementation can be retried from the same spec instead of re-derived from memory.

**Drift becomes visible.** When intent lives nowhere, code cannot contradict it. When intent lives in `spec.md`, a mismatch is a detectable, discussable fact. The stronger variants of the practice keep specs living: implementation reveals a wrong assumption, the spec gets amended, and the document keeps tracking reality instead of fossilizing at kickoff.

## Where it earns its cost, and where it does not

Honesty section. A spec is overhead, and overhead needs to pay rent.

Spec-driven development shines where the cost of misunderstanding is high: features touching real users, multi-day work, anything several agents or people build together, anything you will still be maintaining next year. It is silly for a one-file script, an exploration, a prototype whose whole purpose is to discover what you want. Vibe coding remains exactly right for those, and the mature position is fluency in both, with a deliberate line between them.

Two failure modes to watch as you adopt it. The first is ceremony creep: specs that balloon into waterfall documents, written to satisfy the template rather than to transmit intent. A spec is done when an agent (or a new teammate) could implement from it without asking you anything important; every sentence past that point is decoration. The second is spec rot, the same disease that killed the wiki: documents that no longer describe the system, silently poisoning every agent that reads them. The countermeasure is the same as for AGENTS.md files and any other machine-read context: treat the spec as code, review it, update it when reality diverges, delete it when it lies.

There is also a quieter cultural effect worth naming. Writing a good spec is hard in a way that writing a prompt is not. It forces the decisions that conversational back-and-forth lets you defer. Teams adopting SDD report that the specification phase is where the actual engineering happens now, and that this was, in retrospect, always true; the code was just where we used to discover it.

## Summary

Spec-driven development inverts the AI-assisted workflow: intent becomes a versioned, reviewable document, and code becomes its generated expression, with Spec Kit's specify-plan-tasks-implement pipeline as the current reference implementation. It moves review to the altitude where humans still beat machines, makes work resumable and parallelizable, and turns drift from silent decay into a visible diff. It costs ceremony, so spend it where misunderstanding is expensive and skip it where exploration is the point. Declarative thinking won infrastructure a decade ago. It is now making the same argument about software intent, and the argument is landing.

## Resources

- [**GitHub Spec Kit**](https://github.com/github/spec-kit)
- [**Spec Kit documentation**](https://github.github.com/spec-kit/)
- [**Spec-driven development with AI (GitHub Blog)**](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [**The spec-driven.md manifesto**](https://github.com/github/spec-kit/blob/main/spec-driven.md)
