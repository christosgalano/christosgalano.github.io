---
title: "Azure AI Foundry Agent Service"
excerpt: "Azure AI Foundry Agent Service is a fully managed platform that transforms AI agent development into production-ready workflows, enabling organizations to build, deploy, and scale intelligent agents with enterprise-grade security and governance."
tagline: "Build and deploy AI agents at scale"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/azure/ai-foundry/agent-service/agent-service-the-glue.webp
tags:
  - ai
  - azure
---

## Overview

Azure AI Foundry Agent Service, initially announced as "Azure AI Agent Service", addresses the gap between AI demonstrations and production-ready automation. The service's evolution to its current name reflects its deeper integration with the Azure AI Foundry platform, positioning it as a comprehensive foundation for building intelligent agents rather than just another AI service.

Rather than just conversational interfaces, the service enables agents that can process documents, manage workflows, and automate tasks with reliability suitable for mission-critical operations. The platform combines models, tools, frameworks, and governance into a unified system.

It manages orchestration, state management, content safety, and integrates with enterprise identity and observability systems. The service supports over 1,900 models from multiple providers and provides access to 1,400+ connectors through Azure Logic Apps integration, with built-in multi-agent orchestration for complex workflows.

*Note: Service availability and features may vary by Azure region. Check the [Azure Products by Region](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/) page for current availability.*

## Architecture

The service uses an "assembly line" approach with six core stages:

![Assembly Line Architecture](/assets/images/azure/ai-foundry/agent-service/assembly-line.webp)

1. **Model Selection** - Choose from Azure OpenAI (GPT-4o, GPT-4, GPT-3.5) and other providers like Meta's Llama, Mistral, and Cohere
2. **Customization** - Fine-tune models through prompts, training, or RAG techniques
3. **Tool Integration** - Connect to Bing, SharePoint, Azure AI Search, Logic Apps, Functions, and external APIs
4. **Orchestration** - Automated management of tool calls, state, retries, and execution sequences
5. **Trust and Security** - Built-in Microsoft Entra, RBAC, content filtering, and network isolation
6. **Observability** - Comprehensive logging and tracing through Azure Monitor, including Application Insights for detailed telemetry and performance metrics

## Multi-Agent Orchestration

The platform supports two multi-agent approaches (currently in preview):

![Multi-Agent Orchestration](/assets/images/azure/ai-foundry/agent-service/multi-agent-orchestration.webp)

- **Connected Agents** - Primary agents delegate tasks to specialized sub-agents
- **Multi-Agent Workflows** - Sophisticated orchestration for complex, stateful processes

The service features a unified runtime that merges the Semantic Kernel and AutoGen frameworks, providing developers with seamless access to both ecosystems' capabilities. This unified approach extends to integration with other frameworks like CrewAI, LangGraph, and LlamaIndex, offering flexibility without framework lock-in. The service can interoperate with other platforms through standardized protocols.

## Enterprise Security

Key security features include:

![Security Architecture](/assets/images/azure/ai-foundry/agent-service/security-architecture.webp)

- **Identity Management** - Microsoft Entra integration with on-behalf-of authentication and RBAC
- **Compliance** - Microsoft Purview integration for AI governance, DPIA, and AIA support
- **Network Security** - Private endpoints, VPN support, and bring-your-own infrastructure options
- **Threat Protection** - Microsoft Defender integration for security monitoring

## Development Experience

The platform offers multiple development paths:

- **Agent Playground** - No-code interface for designing and testing agents
- **Azure AI Foundry SDK** - Comprehensive APIs for Python, C#, JavaScript, and Java
- **Built-in Evaluation** - Custom metrics and performance tracking
- **CI/CD Integration** - Standard development workflow support

## Use Cases

Common implementations include:

![Use Cases](/assets/images/azure/ai-foundry/agent-service/use-cases.webp)

- **Customer Service** - Automated inquiry handling with CRM integration
- **Document Processing** - Invoice processing, contract analysis, report generation
- **Business Automation** - Supply chain, financial reporting, approval workflows
- **Research and Analysis** - Competitive intelligence, market research, trend monitoring
- **DevOps** - Code review, testing assistance, system monitoring

## Summary

Azure AI Foundry Agent Service provides a comprehensive platform for enterprise AI automation. Its assembly-line architecture ensures production readiness with built-in security, observability, and governance. The service enables organizations to move beyond AI demonstrations to scalable, reliable automation through flexible development approaches and extensive integration capabilities.

## Resources

- [Azure AI Foundry Agent Service Documentation](https://learn.microsoft.com/en-us/azure/ai-services/agents/overview)
