---
title: "The Agent-Native Repository"
excerpt: "AGENTS.md is now a Linux Foundation standard with adoption in tens of thousands of projects. A practical guide to preparing a repository so coding agents produce work you would actually merge."
tagline: "Agents inherit your repo's habits, so give it good ones"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/agent-native-repository/agent-native-repository.webp
tags:
  - ai
  - github
---

## Overview

The quality of what a coding agent produces in your repository is not primarily a property of the model. It is a property of the repository. The same agent that writes clean, convention-following code in one codebase writes plausible nonsense in another, and the difference is almost always context: what the repository told the agent about itself, and what it left the agent to guess.

For a while, every tool had its own way of receiving that context, and repositories accumulated a small zoo of instruction files. That fragmentation is ending. AGENTS.md, the format OpenAI pioneered for Codex, was donated to the Agentic AI Foundation under the Linux Foundation in December 2025, and it is now read by over 25 agents, Copilot, Cursor, Codex, Devin, Zed, and friends, across tens of thousands of open-source projects. One file, every agent.

Which makes this a good moment for the practical question: what does a repository look like when it is genuinely ready for agents to work in it? Not "has the file", but ready. Here is what I have converged on.

## The instruction file: write down what the code cannot say

The format itself is deliberately boring: standard Markdown, no required fields, no schema. Agents read the nearest AGENTS.md in the directory tree, so monorepos can nest files with proximity-based precedence, general guidance at the root, specifics next to the code they govern.

The absence of a schema means the quality bar is entirely editorial, and this is where most attempts fail. The instinct is to describe the project: what it is, what the directories are, what the stack is. Mostly wasted words. Agents are good at reading code; your directory layout is the one thing they will figure out unaided.

Write down what the code cannot say:

- **Commands that actually work.** The exact build, test, and lint invocations, including the flags and environment quirks. An agent that can verify its own work is an order of magnitude more useful than one that cannot, and it can only verify what you told it how to run.
- **Conventions with reasons.** "We wrap all Azure SDK calls in the client from `internal/azure`, do not call the SDK directly" beats a style essay. The reason matters: agents, like new hires, follow rules better when the rule explains itself.
- **Boundaries.** What must not be touched: generated files, vendored code, migration history, that one directory with the load-bearing hack. An agent cannot respect a fence it cannot see, and Chesterton applies to machines too.
- **Definition of done.** Tests pass, linter clean, docs updated when public surface changes. Agents optimize for the finish line you draw.

Keep it short enough to stay true. A 400-line instruction file drifts out of date within a quarter, and a stale instruction is worse than none, because the agent, unlike the skeptical human, will follow it off the cliff.

## The repository itself: agents amplify what is already there

The file is the visible part. The larger preparation is making the repository legible and self-verifying, and here is the pleasant surprise: everything on this list is just engineering hygiene with a new beneficiary.

**Fast, deterministic checks.** Agents iterate in loops: try, run checks, read failures, retry. A ten-minute flaky test suite doesn't just slow that loop, it poisons it, because the agent cannot distinguish its own mistake from your flakiness. Investment in test speed and determinism now pays double.

**Errors that explain themselves.** An agent debugging "exit code 1" flails; one reading "config key `retention_days` must be a positive integer" fixes and moves on. Every error message in your tooling is now also a prompt.

**Small, coherent modules.** Context windows are finite budgets. A codebase where understanding one behavior requires reading nine files spends the agent's budget on archaeology instead of the change. High cohesion was always good advice; now it has a token cost attached.

**CI as the gate, not the human.** Agent-authored pull requests should flow through the same required checks as everyone else, and those checks should encode your real standards. The instruction file asks nicely; the pipeline enforces. You want both, and you want them to agree, because an agent told one thing by AGENTS.md and another by CI learns to distrust the file.

Notice the theme. Nothing here is agent-exotic. A repository that is good for agents is a repository that would have been good for your next human hire, with tighter feedback loops and clearer rules. The agents just removed the slack that let us defer the work.

## Keeping it honest

Two operational habits separate repositories where this works from repositories where the file is decoration.

Treat AGENTS.md as code. It goes through review, it has owners, and when an agent does something wrong that better instructions would have prevented, the fix lands in the file the same way a bug fix lands in source. The best teams I have seen run a feedback loop: every rejected agent PR gets a one-line diagnosis, and diagnoses that repeat become instructions.

And measure against merges, not activity. The metric that matters is not how many PRs agents open; it is what fraction survives review unmodified. That number is your repository's legibility score, and watching it move as you improve instructions and checks tells you exactly where the remaining friction lives.

## Summary

AGENTS.md gave the ecosystem what it needed: one plain-Markdown instruction file, foundation-governed, read by effectively every coding agent, with nested files for monorepo precision. But the file is the smaller half of readiness. Agents thrive on what good engineering always produces: runnable commands, explained conventions, visible boundaries, fast deterministic checks, and a CI gate that enforces what the instructions describe. Prepare the repository, keep the file honest through review and iteration, and measure by merge rate. The agents are not the hard part. The mirror is.

## Resources

- [**AGENTS.md**](https://agents.md/)
- [**Agentic AI Foundation**](https://www.linuxfoundation.org/)
- [**GitHub Copilot documentation**](https://docs.github.com/en/copilot)
- [**My post on the GitHub Copilot coding agent**](/github-copilot-coding-agent/)
