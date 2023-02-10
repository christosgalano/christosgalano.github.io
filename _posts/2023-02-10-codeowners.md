---
title: "Codeowners"
excerpt: "In this blog post, we'll look at what the CODEOWNERS file is, how it works, and why it's useful for GitHub teams."
tagline: "Granular control over the code in your repository"
header:
  overlay_color: "#24292f"
  teaser: assets/images/codeowners/codeowners.webp
categories:
  - github
toc: true
---

## General

GitHub is a popular software development, collaboration, and version control platform. The CODEOWNERS file in GitHub is a powerful tool for teams to manage access to their codebase and maintain control over code changes. It enables teams to delegate ownership of specific files or directories within a repository to specific individuals or teams.

In this blog post, we'll look at what the CODEOWNERS file is, how it works, and why it's useful for GitHub teams. We will also go over how to effectively use the CODEOWNERS file, including notes, examples and best practices.

## Definition

The CODEOWNERS file is a simple text file that lists the individuals or teams in a GitHub repository who are responsible for reviewing and approving changes to specific files or directories. The file's syntax is similar to that of the `.gitignore` file, with each line representing a file or directory and its owner.

For example, if you have a directory named "docs" that contains all of your project's documentation, you could specify in the CODEOWNERS file that the "docs" team should be the owners of that directory. When someone makes a change to a file in that directory, the owners are notified and can review and approve or reject the change.

## Benefits

The CODEOWNERS file is a useful tool for several reasons:

- **Codebase ownership**: The CODEOWNERS file specifies who is responsible for maintaining specific parts of a codebase. This is especially important in large projects with many contributors, where keeping track of who is responsible for which parts of the code can be difficult.

- **Code review**: By specifying the owners for specific files or directories, someone can ensure that changes to those parts of the codebase are reviewed by the appropriate individuals, as code owners are automatically requested for review when a pull request that modifies code that they own is opened. This helps to maintain the codebase's quality and consistency while lowering the risk of bugs or other problems slipping through the cracks.

- **Collaboration**: The CODEOWNERS file can also help encourage team collaboration by identifying who is responsible for which parts of the code. As a result, the development process can move along more quickly because changes will be reviewed and approved quite faster.

## Usage

Using the CODEOWNERS file is simple and straightforward. Here’s how to get started:

Create a new file called `CODEOWNERS` in the root, `docs/`, or `.github/` directory of the repository, in the branch where you'd like to add the code owners. Each CODEOWNERS file in the repository assigns code owners to a single branch.

Open the file in a text editor and add the file or directory paths that you want to specify owners for, followed by a space or tab and the username or team name of the owners. For example, if you want to specify that the “docs” team is the owner of the “docs” directory, you would add the following line to the `CODEOWNERS` file:

{% highlight bash %}
docs/ @docs
{% endhighlight %}

It should be noted that the syntax for specifying team owners differs slightly from that for specifying individual owners. Individual owners should use the username, while teams should use the "@" symbol followed by the team name.

Commit and push the changes to the repository. Once you’ve added the `CODEOWNERS` file to your repository, it will be in effect immediately. When someone makes a change to a file or directory specified in the `CODEOWNERS` file, the owners will receive a notification and will be able to review and approve or reject the change.

## Example

Consider a repository for a web application that has separate folders for each environment, such as development, staging, and production. The repository might look like this:

{% highlight bash %}
my-web-app/
  development/
  staging/
  production/
{% endhighlight %}

In this scenario, you may want to specify different owners for each environment folder. For example, the development folder may be owned by a group of developers, while the staging and production folders may be owned by a different group of individuals responsible for quality assurance and deployment.

You can specify the owners in the `CODEOWNERS` file like this:

{% highlight bash %}
development/ @devs
staging/ @qas
production/ @deployers
{% endhighlight %}

When changes are made to the development folder, the development team is notified and can review and approve the changes. When changes are made to the staging or production folders, the appropriate teams are made aware and therefore can review and approve the changes.

By using the CODEOWNERS file in this manner, you can ensure that changes are properly vetted before being deployed to each environment, and that the right people are in charge of managing the corresponding code.

## Notes

- Be careful how you order your definitions; the last matching pattern takes precedence.

- In most cases, you can also refer to a user by their GitHub.com email address, such as demo-user@examplemail.com. A managed user account cannot be referred to using an email address.

- CODEOWNERS paths are case-sensitive because GitHub uses a case-sensitive file system, so even case-insensitive systems must use correctly cased paths and files in the CODEOWNERS file.

- Any line in your CODEOWNERS file with incorrect syntax will be skipped. All errors are highlighted when you navigate to the CODEOWNERS file in your GitHub.com repository.

## Best practices

- **Use wildcards**: In the CODEOWNERS file, you can use wildcards to specify owners for multiple files or directories at once.

- **Specify multiple owners**: Multiple owners can be specified for a single file or directory by listing them on separate lines.

- **Inheritance**: Because the CODEOWNERS file supports inheritance, you can specify owners for a parent directory and have those owners apply to subdirectories as well.

- **Use teams**: If you have a large project with many contributors, using teams rather than individual owners may be more efficient. GitHub teams can be formed and include multiple individuals, making it simple to manage access to the codebase for large groups of people.

## Point of reference

Copied from this [GitHub post](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners):

{% highlight bash %}
# This is a comment.
# Each line is a file pattern followed by one or more owners.

# These owners will be the default owners for everything in
# the repo. Unless a later match takes precedence,
# @global-owner1 and @global-owner2 will be requested for
# review when someone opens a pull request.
*       @global-owner1 @global-owner2

# Order is important; the last matching pattern takes the most
# precedence. When someone opens a pull request that only
# modifies JS files, only @js-owner and not the global
# owner(s) will be requested for a review.
*.js    @js-owner #This is an inline comment.

# You can also use email addresses if you prefer. They'll be
# used to look up users just like we do for commit author
# emails.
*.go docs@example.com

# Teams can be specified as code owners as well. Teams should
# be identified in the format @org/team-name. Teams must have
# explicit write access to the repository. In this example,
# the octocats team in the octo-org organization owns all .txt files.
*.txt @octo-org/octocats

# In this example, @doctocat owns any files in the build/logs
# directory at the root of the repository and any of its
# subdirectories.
/build/logs/ @doctocat

# The `docs/*` pattern will match files like
# `docs/getting-started.md` but not further nested files like
# `docs/build-app/troubleshooting.md`.
docs/*  docs@example.com

# In this example, @octocat owns any file in an apps directory
# anywhere in your repository.
apps/ @octocat

# In this example, @doctocat owns any file in the `/docs`
# directory in the root of your repository and any of its
# subdirectories.
/docs/ @doctocat

# In this example, any change inside the `/scripts` directory
# will require approval from @doctocat or @octocat.
/scripts/ @doctocat @octocat

# In this example, @octocat owns any file in a `/logs` directory such as
# `/build/logs`, `/scripts/logs`, and `/deeply/nested/logs`. Any changes
# in a `/logs` directory will require approval from @octocat.
**/logs @octocat

# In this example, @octocat owns any file in the `/apps`
# directory in the root of your repository except for the `/apps/github`
# subdirectory, as its owners are left empty.
/apps/ @octocat
/apps/github
{% endhighlight %}

## Summary

To summarize, the CODEOWNERS file in GitHub is a powerful tool for teams to manage access to their codebase and maintain control over code changes. Whether you’re working on a small project or a large one, the CODEOWNERS file can help maintain the quality and consistency of the codebase, encourage collaboration, and speed up the development process by specifying the individuals or teams responsible for reviewing and approving changes to specific files or directories.

## Resources

**Related documentation:** [About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
