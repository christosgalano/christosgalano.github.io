---
title: "GitHub Copilot Coding Agent"
excerpt: "GitHub Copilot's Coding Agent is an autonomous AI assistant that works asynchronously on issues, creating and iterating on pull requests like a teammate."
tagline: "Assign issues to AI and get tested pull requests in return."
header:
  overlay_color: "#24292f"
  teaser: https://github.blog/wp-content/uploads/2025/06/Copilot_Coding_Agent_header.jpg
tags:
  - ai
  - github
---

## What is the GitHub Copilot Coding Agent?

The GitHub Copilot Coding Agent is GitHub's first autonomous, asynchronous software development agent that can work independently on issues and create pull requests. Unlike traditional AI coding assistants that provide suggestions while you code, this agent operates like a teammate—you assign it work, and it delivers tested solutions.

![Feature Overview](https://github.blog/wp-content/uploads/2025/05/CodingAgent_ChangelogHeader_003.jpg)
*Overview of GitHub Copilot Coding Agent capabilities and workflow.*

Main capabilities:
- Accept issue assignments and work autonomously in the background
- Create and iterate on pull requests with complete workflows
- Run tests, linters, and builds to validate changes
- Respond to feedback and code review comments
- Integrate with GitHub Actions for secure, isolated execution
- Support Model Context Protocol (MCP) for extended capabilities

> The GitHub Copilot Coding Agent is currently in public preview for GitHub Copilot Pro, Pro+, Business, and Enterprise users.

## Why use the Coding Agent?

The Coding Agent transforms how development teams handle routine tasks by working asynchronously on your behalf. It enables teams to:

- **Delegate routine work**: Assign low-to-medium complexity tasks to focus on strategic work
- **Maintain development flow**: Continue working while the agent handles background tasks
- **Reduce context switching**: No need to stop current work for maintenance tasks
- **Scale team capacity**: Handle more issues simultaneously with AI assistance
- **Improve code quality**: Consistent application of coding standards and testing practices

## Getting Started

### Prerequisites

The Coding Agent requires:
- GitHub Copilot Pro, Pro+, Business, or Enterprise subscription
- Repository write access for users assigning issues
- Enabled in organization settings (for Business/Enterprise plans)

### Enabling the Agent

For **individual accounts**:
- **Copilot Pro+**: The agent is enabled by default.
- **Copilot Pro**: The agent is available, but enablement status may require verification in your account settings.

For **organizations** (Business/Enterprise):
1. Navigate to organization settings
2. Go to **Copilot** → **Coding agent**
3. Enable the feature for your organization
4. Configure optional MCP servers and custom instructions

### Your First Assignment

To start using the coding agent:

1. **Create a well-scoped issue** with clear requirements and acceptance criteria
2. **Assign the issue to `@copilot`** like you would assign to any team member

After completing the steps above, here's how the workflow looks in practice:

![Assigning an Issue to Copilot](https://docs.github.com/assets/cb-25260/images/help/copilot/coding-agent/assign-to-copilot.png)
*Assigning an issue to Copilot in the GitHub interface.*

3. **Wait for the 👀 (eyes) reaction** confirming the agent has accepted the assignment
4. **Monitor progress** through the automatically created draft pull request
5. **Review and iterate** using standard pull request workflows

## How the Agent Works

### Secure Development Environment

When assigned a task, the agent:
- Spins up a secure, ephemeral development environment using GitHub Actions
- Clones the repository and analyzes the codebase using GitHub's RAG-powered code search
- Configures the environment according to repository settings and custom instructions
- Maintains isolation with controlled internet access and branch protections

![Issue Assignment Flow](https://docs.github.com/assets/cb-64185/images/help/copilot/coding-agent/issue-assigned-to-copilot.png)
*Visual workflow: Issue assigned to Copilot and tracked in the repository.*

### Autonomous Development Process

The agent follows a structured approach:

1. **Analysis**: Reviews the issue description, related PRs, and codebase context
2. **Planning**: Creates a step-by-step plan visible in the pull request description

![Pull Request Creation](https://docs.github.com/assets/cb-73703/images/help/copilot/coding-agent/issue-link-to-pr.png)
*Copilot creates a draft pull request linked to the assigned issue.*

3. **Implementation**: Makes code changes across multiple files as needed
4. **Validation**: Runs tests, linters, and builds to ensure code quality
5. **Documentation**: Updates the PR description with progress and reasoning

### Detailed Session Monitoring

Agent session logs provide complete transparency into the agent's decision-making process, showing its internal reasoning as it analyzes your codebase, plans changes, and validates its work. This detailed "internal monologue" is visible throughout the development process.

### Code Review and Iteration

The agent creates draft pull requests that integrate seamlessly with existing workflows:

- **Standard PR workflow**: Review changes like any other team contribution
- **Responsive iteration**: Leave comments and the agent will address feedback
- **Quality gates**: All existing branch protections and CI/CD requirements apply
- **Human oversight**: Manual approval required for GitHub Actions workflow execution

![Agent Progress Tracking](https://docs.github.com/assets/cb-102994/images/help/copilot/coding-agent/agents-page.png)
*Track the agent's progress and session logs in the GitHub UI.*

## Agent vs Agent Mode: Key Differences

Understanding the distinction between GitHub Copilot's **Coding Agent** and **Agent Mode** is crucial:

| Feature | Coding Agent | Agent Mode |
|---------|------------------|------------|
| **Execution** | Asynchronous, cloud-based | Synchronous, local IDE |
| **Scope** | Complete issues with PR workflows | Multi-step tasks in editor |
| **Environment** | GitHub Actions sandbox | Your local development environment |
| **Workflow** | Issue assignment → PR creation → Review | Real-time collaboration in editor |
| **Best for** | Background tasks, delegation | Active development sessions |

![Agent vs Agent Mode Visualization](https://code.visualstudio.com/assets/blogs/2025/02/24/agent-mode.png)
*Comparison of Coding Agent and Agent Mode features and workflows.*

## Advanced Configuration

### Model Context Protocol (MCP)

The agent supports MCP servers to extend capabilities beyond the default integrations:

**Default MCP Servers**:
- **GitHub MCP**: Access to issues, PRs, and repository data
- **Playwright MCP**: Web browser automation for testing UI changes

**Custom MCP Configuration**: Repository administrators can configure additional MCP servers through repository settings to provide specialized tools and data access.

### Custom Instructions

Repository-level instructions help the agent understand your coding standards, testing frameworks, and architectural patterns. These can be added via repository settings or configuration files to ensure consistent code quality.

## Good Practices

### Ideal Tasks for the Agent

**Well-suited tasks**:
- Bug fixes with clear reproduction steps
- Feature additions with defined scope
- Test coverage improvements
- Documentation updates
- Dependency upgrades
- Code style refactoring

**Tasks to handle yourself**:
- Complex architectural decisions
- Security-sensitive implementations
- Broad, undefined requirements
- Production incident response
- Tasks requiring deep domain knowledge

### Writing Effective Issues

The quality of results depends heavily on well-structured issues:

{% highlight markdown %}
{% raw %}
## Problem
Clear description of what needs to be fixed or implemented

## Acceptance Criteria
- Specific requirements for the solution
- Testing expectations
- Quality standards

## Context
- Relevant file paths
- Dependencies or constraints
- Related issues or PRs
{% endraw %}
{% endhighlight %}

## Resource Usage and Costs

### Typical Usage Patterns

The Coding Agent consumes both **GitHub Actions minutes** (for the development environment) and **premium requests** (for model inference):

- **Premium requests**: Expect 30-50 premium requests per agent session
- **GitHub Actions minutes**: Usage scales with task complexity and iteration cycles
- **Cost planning**: Monitor usage through your GitHub billing dashboard

### Resource Planning Considerations

Usage varies significantly based on:
- Task complexity and scope
- Number of files modified
- Review and iteration cycles
- Testing and validation requirements

For effective resource planning, consider that more complex or iterative tasks will consume more Actions minutes and premium requests. Start with simpler, well-defined tasks to understand your usage patterns.

## Security and Limitations

### Security Measures

The agent includes built-in security protections:
- **Isolated execution**: Runs in ephemeral GitHub Actions environment
- **Limited permissions**: Cannot access organization secrets without explicit configuration
- **Branch protections**: Prevents direct pushes to protected branches
- **Firewall enabled**: Prevents data exfiltration by default
- **Audit trails**: All actions logged for transparency

### Current Limitations

- **Scope sensitivity**: Works best with well-defined, medium-complexity tasks
- **Language support**: Optimized for popular programming languages
- **Context limitations**: May struggle with very large codebases
- **Domain specificity**: Limited effectiveness in highly specialized domains

## Resources

- [**Coding Agent Documentation**](https://docs.github.com/en/copilot/how-tos/agents/copilot-coding-agent)
- [**Best Practices Guide**](https://docs.github.com/en/copilot/using-github-copilot/coding-agent/best-practices-for-using-copilot-to-work-on-tasks)
- [**Assigning Tasks Tutorial**](https://docs.github.com/en/copilot/using-github-copilot/coding-agent/using-copilot-to-work-on-an-issue)
- [**MCP Configuration**](https://docs.github.com/copilot/customizing-copilot/using-model-context-protocol/extending-copilot-coding-agent-with-mcp)
