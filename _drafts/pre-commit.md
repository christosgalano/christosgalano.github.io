---
title: "pre-commit"
excerpt: "Discover how pre-commit can automate code quality checks and improve your development workflow with practical examples."
tagline: "Automate code checks, ensure quality, and simplify your commits with pre-commit."
header:
  overlay_color: "#24292f"
  teaser: /assets/images/pre-commit/pre-commit.webp
tags:
  - miscellaneous
---

## Introduction

Maintaining code quality is crucial, whether you're a software developer, data scientist, devops engineer, or anyone working with code in a Git repository. Writing clean and consistent code can be challenging, especially when collaborating with others or managing large projects. Tools like pre-commit help automate this process by running various inspection and formatting tools on your code before you commit it to a version control system. In this post, we'll explore what pre-commit is, how it works, what it can offer, and provide an example of its usage.

## What is pre-commit?

pre-commit is a versatile framework designed to manage and run a suite of tools that inspect, format, or modify your code before it is committed to a version control system like Git. These tools, known as hooks, perform various tasks such as:

- Checking for syntax errors, bugs, or code smells
- Formatting your code according to style guides
- Sorting imports
- Removing trailing whitespace
- Adding or removing license headers or docstrings
- Checking for security vulnerabilities
- Running tests or code analysis tools

By automating these checks, pre-commit helps you identify and resolve common errors, enforce coding standards, and enhance the performance and security of your code.

## How does it work?

pre-commit operates by installing and executing hooks—scripts that perform specified checks and corrections on your code. When you run  `git commit`, pre-commit intercepts the process executes the configured hooks, and permits the commit only if all hooks pass. This proactive approach helps catch issues early and maintains a high standard of code quality.

Some key features of pre-commit include:
- **Multi-language support**: pre-commit supports hooks written in various programming languages.
- **Ease of use**: Simple configuration and integration with Git.
- **Customizable**: Choose from a wide range of pre-configured hooks or write your own.
- **Automated enforcement**: Automatically ensures code quality checks are performed consistently.

## Getting started

To get started with pre-commit, follow these steps:

1. **Install pre-commit**: You can install pre-commit using pip or Homebrew.
2. **Create a configuration file**: Add a `.pre-commit-config.yaml` file to the root of your repository.
3. **Install the pre-commit hooks**: Run `pre-commit install` to install the hooks specified in the configuration file.
4. **Run pre-commit on all files**: Execute `pre-commit run --all-files` to run the hooks on all files in the repository.

{% highlight bash %}
{% raw %}
# Install pre-commit
## Using pip
pip install pre-commit

## Using Homebrew (macOS)
brew install pre-commit

# Install pre-commit in your repository
pre-commit install

# Run pre-commit on all files
pre-commit run --all-files
{% endraw %}
{% endhighlight %}

## Example usage

To illustrate how pre-commit works, let's consider a scenario where you have a repository with YAML, JSON, and Terraform files. You want to ensure that all files are correctly formatted and free of errors before committing them. Here's how you can set up pre-commit to enforce these checks:

{% highlight yaml %}
{% raw %}
repos:
- repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
  - id: check-yaml
  - id: check-json
  - id: trailing-whitespace
- repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.88.0
    hooks:
  - id: terraform_fmt
{% endraw %}
{% endhighlight %}

The configuration file specifies two repositories with hooks that perform the following tasks:

- **check-yaml**: Validates YAML files.
- **check-json**: Validates JSON files.
- **trailing-whitespace**: Removes trailing whitespace.
- **terraform_fmt**: Formats Terraform files according to the standard.

When you make changes to your code and attempt to commit them, pre-commit will run the configured hooks. For example, if you have a YAML file with syntax errors, the `check-yaml` hook will catch it and prevent the commit:

{% highlight bash %}
{% raw %}
$ git commit -m "Add new YAML configuration"
Check Yaml............................................................Failed
- hook id: check-yaml
- exit code: 1
...
{% endraw %}
{% endhighlight %}

## Summary

pre-commit is a powerful tool that helps maintain code quality by automating checks and fixes before commits. By integrating pre-commit into your workflow, you can ensure consistent code standards and catch issues early in the development process. This makes it an invaluable addition to any developer's toolkit, helping you produce cleaner, more reliable code.

## Resources

- [**pre-commit Documentation**](https://pre-commit.com/)
- [**pre-commit Hooks Repository**](https://github.com/pre-commit/pre-commit-hooks)
- [**Terraform pre-commit Hooks**](https://github.com/antonbabenko/pre-commit-terraform)
