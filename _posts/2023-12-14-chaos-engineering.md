---
title: "Chaos Engineering"
excerpt: "Discovering the principles and benefits of chaos engineering."
tagline: "Enhancing system resilience through controlled chaos"
header:
  overlay_color: "#24292f"
  teaser: assets/images/testing/chaos-engineering.webp
tags:
  - testing
  - chaos-engineering
toc: true
related: true
---

## Overview

With the surge of microservices and distributed cloud architectures, the web has evolved into a more intricate landscape. Our reliance on these systems has heightened, yet predicting failures has become increasingly challenging. These disruptions not only affect companies but also impact customers who rely on these services for their daily tasks. Even brief outages can significantly affect the overall health of an organization. Given the high stakes, waiting for the next costly outage is not an option. To tackle this challenge head-on, more and more companies are turning to Chaos Engineering.

## Chaos Engineering is Preventive Medicine

Chaos Engineering is a disciplined approach to identifying failures before they result in outages. By proactively testing how a system responds under stress, you can identify and fix failures before they become headline news. In essence, Chaos Engineering involves breaking things intentionally to learn how to build more resilient systems.

But what are the key principles of Chaos Engineering? Let's delve into the details ...

## Chaos in Practice

Chaos Engineering involves a systematic approach to understanding and enhancing the resilience of distributed systems. In this process, the control group represents the stable, expected behavior of the system, serving as a reference point. The experimental group, on the other hand, is subjected to intentional disruptions or chaos events. The goal is to identify weaknesses in the system by comparing the behavior of the control and experimental group.

In order to achieve this goal, Chaos Engineering experiments are conducted following a four-step approach:

1. **Steady State Definition:** Start by defining *steady state* as a measurable output of the system indicating normal behavior.

2. **Hypothesis Formation:** Hypothesize that this steady state will continue in both the control and the experimental group.

3. **Variable Introduction:** Introduce variables that mirror real-world events, such as server crashes, driver malfunctions, or severed network connections.

4. **Hypothesis Testing:** Attempt to disprove the hypothesis by looking for differences in steady state between the control and the experimental group.

The ability to disrupt the steady state determines the confidence in the system's behavior. If weaknesses are found, they become targets for improvement before they affect the entire system.

## Example

To illustrate the Chaos Engineering process, let's consider a simple example. Suppose you have a web application that uses a database to store user information. You want to ensure that the application remains available even if the database goes down. You can do so by running a Chaos Engineering experiment as follows:

1. **Steady State Definition:** The steady state is defined as the application being available and responsive.
2. **Hypothesis Formation:** The hypothesis is that the application will remain available and responsive even if the database goes down.
3. **Variable Introduction:** The variable is the database. You can simulate a database failure by shutting down the database.
4. **Hypothesis Testing:** The hypothesis is disproved if the application becomes unavailable or unresponsive.

This process can be applied to complex systems with multiple components. By running experiments, you can identify weaknesses and fix them before they cause outages.

## Advanced Principles

Advanced principles define an ideal application of Chaos Engineering, strengthening the confidence in distributed systems at scale:

1. **Build a Hypothesis around Steady State Behavior:** Focus on measurable outputs, like throughput, error rates, and latency percentiles, as indicators of steady state behavior. This approach verifies that the system does work, rather than how it works.

2. **Vary Real-world Events:** Chaos variables should reflect real-world events, prioritized based on potential impact and estimated frequency. This encompasses hardware and software failures, non-failure events, and more, with the potential to disrupt steady state.

3. **Run Experiments in Production:** To truly understand system behavior, experiments should be conducted in production environments. Systems react differently based on environmental conditions and traffic patterns, making experimentation with real traffic the most authentic approach.

4. **Automate Experiments to Run Continuously:** Manual experiment management is labor-intensive and unsustainable. Automation plays a pivotal role in both orchestrating and analyzing experiments, ensuring they run continuously.

5. **Minimize Blast Radius:** While experimenting in production environments carries the risk of temporary disruptions, Chaos Engineers bear the responsibility of ensuring that any adverse effects are minimized and contained.

## Which Chaos Engineering Experiments to Perform First?

In the Chaos Engineering realm, it's crucial to prioritize experiments in a logical order:

1. **Known Knowns (KK)**: These are things you are aware of and fully understand.

2. **Known Unknowns (KU)**: These are scenarios you are aware of but don't fully comprehend.

3. **Unknown Knowns (UK)**: These are things you understand but are not aware of.

4. **Unknown Unknowns (UU)**: These are scenarios you neither know nor fully understand.

By following this logical progression, teams can identify vulnerabilities and prepare for different failure scenarios.

## Benefits of Chaos Engineering

- **Prevent Outages**: Maintain uninterrupted services by identifying and resolving system weaknesses before they lead to costly outages.
- **Reduce Mean Time to Recovery (MTTR)**: Minimize downtime and recovery time by proactively addressing vulnerabilities, ensuring quick issue resolution.
- **Enhance Mean Time Between Failures (MTBF)**: Prolong system stability by identifying and rectifying weaknesses, reducing the frequency of failures.
- **Elevate Customer Experience**: Improve the quality of customer experiences by preemptively managing weaknesses to minimize disruptions.
- **Optimize Cost Efficiency**: Identify and mitigate weaknesses to save resources and reduce operational costs effectively.
- **Boost Confidence**: Enhance confidence in the resilience of systems and ensure reliable operations.

## Summary

Chaos Engineering is a practical approach for enhancing the reliability and resilience of modern digital systems. By identifying and addressing vulnerabilities systematically, you can confidently navigate the complexities of distributed systems, ensuring uninterrupted services, efficient operations, and improved customer experience. After all, we all need a little chaos in our lives ...

## Resources

- [**Principles of Chaos Engineering**](https://principlesofchaos.org/)
