---
title: "The Only Name in the Postmortem"
excerpt: "Every agentic coding decision that ships still passes through exactly one identifiable human moment: approval. This piece sits with what that checkpoint was built for, what it now carries, and does not pretend to close the gap."
tagline: "One click still owns everything it never produced"
header:
  overlay_image: /assets/images/thought-provoking/the-only-name-in-the-postmortem/the-only-name-in-the-postmortem.webp
  caption: "René Magritte, The Human Condition (1933)"
  teaser: /assets/images/thought-provoking/the-only-name-in-the-postmortem/the-only-name-in-the-postmortem.webp
tags:
  - thought-provoking
  - ai
---

Two weeks ago I approved a pull request I hadn't actually read, not the way review used to mean it. An agent had touched nine files across three services, refactoring how our auth middleware handled token refresh. I opened the diff, recognized the shapes, watched the tests go green, and clicked approve. I understood what the change did. I couldn't have told you why it did it that way instead of the four other ways that would have also passed the tests.

That is not a confession of laziness. Scrutinizing every line of agent-produced code, at the volume and speed most of us now run it, stopped being possible a while ago. I know this because I tried, for about a month, to hold the old standard. I fell behind everyone I work with, including the agent.

## The One Moment

Here is the part that has not changed, no matter how much else has: every change that ships still passes through exactly one identifiable human moment. Someone approves the pull request. Someone clicks merge. Someone presses deploy. That single checkpoint is the entire accountability structure we have.

It was not built to be a chokepoint. It was built to be a confirmation, a second look at a decision someone had already reasoned through, mostly the same someone who was about to click the button.

## A Slower Design

That checkpoint assumes the reasoning behind a change happened somewhere visible, usually inside the head of the person now approving it, or a colleague who explained it in a comment thread you could still find. The approval was fast because the thinking behind it was already done in the open.

Agents did not remove the checkpoint. They removed the visible reasoning that used to sit behind it, and left the checkpoint standing alone, now expected to certify work whose actual deliberation happened somewhere I cannot fully see and, a week later, cannot always reconstruct even with the conversation log open in another tab. The gate got no wider. What has to pass through it got heavier.

## Nothing To Revoke

Run the incident review forward. Five whys, the standard drill: why did the bug ship, why did review miss it, why did the reviewer trust that section, why, why. At some point in that chain, more of the actual "why" was answered by the agent's reasoning than by mine. Doesn't matter. The chain still terminates at a name, and it is always a human one, because a name is the only thing an org chart knows how to hold.

You cannot put a model in a postmortem. Revoking its access is not accountability, it is a configuration change, applied the same way whether the model reasoned brilliantly or badly. The postmortem needs a person who could have done differently. It gets me, holding a diff I trusted more than I inspected.

## No Middle Setting

Tighten review to compensate and you have quietly cancelled the reason anyone adopted agents in the first place. Speed was the whole pitch. Leave review as it was and you are certifying reasoning you did not produce, running at a pace where you increasingly cannot retrace it either.

I don't think there is a setting between those two that resolves it. More gates slow the thing gates exist to speed up. Fewer gates make the one gate left carry weight it was never sized for. I have tried both directions this year, on the same team, and both were true at once, not one problem cured before the other showed up.

Writing the intent down first, so the spec survives the session and someone can trace what was meant, helps with a different problem: the archaeology of figuring out what a change was for. It does not touch this one. A well-documented decision is still a decision I approved without fully retracing the path to it. The paper trail makes the record more complete. It does not make the record answer whether I was right to sign it.

## What Doesn't Close

I can open the repository right now and find the exact commit where I clicked approve on that auth middleware change. Timestamp, hash, my name in the merge log, all of it permanent and searchable.

I cannot find the commit where I actually understood, the way I would have needed to in order to defend the choice from first principles, what the agent had decided and why it decided that instead of something else. That moment may never have existed at all, and no review gate, no spec, no amount of process between here and the next release is going to manufacture it after the fact.

---

*I can point to the commit where I approved it. I have stopped expecting to find the moment I actually understood it.*
