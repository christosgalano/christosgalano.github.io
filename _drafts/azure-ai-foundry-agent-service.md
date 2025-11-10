---
title: "Azure AI Foundry Agent Service"
excerpt: "Azure AI Foundry Agent Service is a managed platform designed to help organizations build, deploy, and manage AI agents with built-in security, governance, and scale."
tagline: "Build and deploy AI agents at scale"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/azure/ai-foundry/agent-service/agent-service-the-glue.webp
tags:
  - ai
  - azure
---

## Overview

Azure AI Foundry Agent Service helps turn AI prototypes into production-ready automation.  
Originally launched as *Azure AI Agent Service*, it now anchors the Azure AI Foundry platform — not just another AI tool, but a foundation for enterprise-grade agents.

**What it does:**  
- Beyond chatbots: process documents, manage workflows, automate business tasks  
- Orchestrates models and tools with built-in governance and observability  
- Handles state, retries, content safety, and enterprise integration  

**Scale:**  
- Large catalog of models, including GPT-4o, GPT-4, GPT-3.5, Llama, Mistral, and Cohere  
- 1,400+ connectors via Logic Apps  
- Multi-agent orchestration for complex workflows (GA)  

> Availability varies by region. See [Azure Products by Region](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/).

---

## Architecture

The service follows an "assembly line" approach, with six conceptual stages:

![Assembly Line Architecture](/assets/images/azure/ai-foundry/agent-service/assembly-line.webp)

1. **Model Selection**: Choose from Azure OpenAI and other foundation models  
2. **Customization**: Tune via prompts, fine-tuning, or retrieval-augmented generation (RAG)  
3. **Tool Integration**: Connect to Bing, SharePoint, Azure AI Search, Logic Apps, Functions, or external APIs  
4. **Orchestration**: Manage tool calls, state, retries, and execution sequences  
5. **Trust & Security**: Microsoft Entra, RBAC, content filtering, and network isolation  
6. **Observability**: Logging and tracing with Azure Monitor and Application Insights  

---

## Multi-Agent Orchestration

Two supported modes:

![Multi-Agent Orchestration](/assets/images/azure/ai-foundry/agent-service/multi-agent-orchestration.webp)

- **Connected Agents**: A primary agent delegates tasks to specialists  
- **Multi-Agent Workflows**: Stateful, complex processes spanning multiple agents  

**Example:** A support agent routes billing issues to a finance agent, product issues to a knowledge agent, and compliance checks to a policy agent.

Agents run on a unified runtime that converges **Semantic Kernel** and **AutoGen**, while also supporting external frameworks like CrewAI, LangGraph, or LlamaIndex. Designed for interoperability, not strict lock-in.

---

## Enterprise Security

![Security Architecture](/assets/images/azure/ai-foundry/agent-service/security-architecture.webp)

- **Identity**: Microsoft Entra with on-behalf-of auth and RBAC  
- **Compliance**: Microsoft Purview for AI governance, DPIA, and AIA support  
- **Network**: Private endpoints, VPN support, BYO infrastructure  
- **Threat Protection**: Microsoft Defender integration for monitoring  

---

## Development Experience

Choose your path:  
- **Agent Playground**: No-code design and testing  
- **Azure AI Foundry SDK**: APIs for Python, C#, JavaScript, and Java  
- **Evaluation Tools**: Built-in metrics for tool accuracy and task adherence  
- **CI/CD Ready**: Works with standard pipelines  

---

## Use Cases

![Use Cases](/assets/images/azure/ai-foundry/agent-service/use-cases.webp)

- **Customer Service**: CRM-integrated inquiry handling  
- **Document Processing**: Invoices, contracts, and reports  
- **Business Automation**: Supply chain, reporting, approvals  
- **Research & Analysis**: Market trends, competitive intelligence  
- **DevOps**: Code review, testing, monitoring  

---

## Summary

Azure AI Foundry Agent Service bridges the gap between AI experiments and enterprise-scale automation.  
Its "assembly-line" architecture ensures **production readiness** with security, observability, and governance built in.  

Organizations can move beyond demos to scalable AI workflows with flexible development options and deep integration across Azure and external systems.

---

## Resources

- [Azure AI Foundry Agent Service Documentation](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/overview)
- [GA Announcement Blog](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/announcing-general-availability-of-azure-ai-foundry-agent-service/4414352)
