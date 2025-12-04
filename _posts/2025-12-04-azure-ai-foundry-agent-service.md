---
title: "Azure AI Foundry Agent Service"
excerpt: "Azure AI Foundry Agent Service is a managed platform that helps organizations build, deploy, and operationalize AI agents with enterprise-grade security, governance, and scale."
tagline: "Build and deploy AI agents with confidence"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/azure/ai-foundry/agent-service/agent-service-the-glue.webp
tags:
  - ai
  - azure
---

## Overview

Azure AI Foundry Agent Service helps teams move from AI prototypes to production-ready automation. Initially introduced as *Azure AI Agent Service*, it now anchors the broader Azure AI Foundry platform.

**What it does:**  
- Goes beyond chat: process documents, manage workflows, automate multi-step business tasks  
- Orchestrates models and tools with governance and observability included by default  
- Handles state, retries, content safety, and enterprise integration primitives  

**Scale:**  
- Supports Azure OpenAI models and selected open-source models (e.g., Llama, Mistral), depending on region  
- 1,400+ Logic Apps connectors for enterprise systems  
- Multi-agent orchestration available (some capabilities remain in preview)

> Availability depends on region. See Azure Products by Region.

## Architecture

The service follows a conceptual "assembly line" approach.

![Assembly Line Architecture](/assets/images/azure/ai-foundry/agent-service/assembly-line.webp)

1. **Model Selection**: Azure OpenAI + selected OSS models  
2. **Customization**: Prompts, fine-tuning, RAG  
3. **Tool Integration**: Bing Search, SharePoint, Azure AI Search, Logic Apps, Functions, custom APIs  
4. **Orchestration**: Tool calls, state, sequencing, retries  
5. **Trust & Security**: Entra ID, RBAC, content safety, VNet isolation  
6. **Observability**: Azure Monitor + Application Insights tracing

## Multi-Agent Orchestration

Two supported patterns:

![Multi-Agent Orchestration](/assets/images/azure/ai-foundry/agent-service/multi-agent-orchestration.webp)

- **Connected Agents**: A primary agent delegates tasks to specialized sub-agents (preview)  
- **Multi-Agent Workflows**: Stateful workflows spanning multiple agents (preview/GA mix depending on feature)

**Example:** A support agent routes billing issues to a finance agent, product questions to a knowledge agent, and compliance checks to a policy agent.

The runtime brings together concepts from **Semantic Kernel** and **AutoGen** and supports external frameworks such as CrewAI, LangGraph, and LlamaIndex.

---

## Enterprise Security

![Security Architecture](/assets/images/azure/ai-foundry/agent-service/security-architecture.webp)

- **Identity**: Microsoft Entra + RBAC + on-behalf-of authentication  
- **Compliance**: Integrates with Microsoft Purview for AI governance workflows  
- **Network**: Private endpoints, VNet integration, isolation options  
- **Threat Protection**: Defender for Cloud + integrated monitoring

## Development Experience

Multiple development paths:

- **Agent Playground**: Visual/no-code design and testing  
- **Azure AI Foundry SDKs**: Python, C#, TypeScript/JavaScript, Java  
- **Evaluation Tools**: Metrics for tool robustness and task adherence  
- **CI/CD Friendly**: Works with Azure DevOps, GitHub Actions, and standard pipelines

## Use Cases

![Use Cases](/assets/images/azure/ai-foundry/agent-service/use-cases.webp)

- **Customer Service**: CRM-linked intelligent routing and response  
- **Document Processing**: Invoices, contracts, knowledge extraction  
- **Business Automation**: Approvals, supply chain, reporting flows  
- **Research & Analysis**: Trend analysis, summarization, monitoring  
- **DevOps**: Code review helpers, environment checks, operations bots

## Summary

Azure AI Foundry Agent Service bridges the gap between AI experiments and enterprise-ready automation.  
Its opinionated runtime — with built-in security, observability, and governance — helps organizations move beyond demos and into scalable, trustworthy agent workflows.

## Resources

- [Service Overview](https://learn.microsoft.com/azure/ai-foundry/agents/overview)  
- [General Availability Announcement](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/announcing-general-availability-of-azure-ai-foundry-agent-service/4414352)
