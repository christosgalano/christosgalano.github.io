# METADATA
# scope: package
# description: A set of rules to enforce constraints on Azure DevOps Projects.

package terraform.azuredevops.project

import rego.v1

import data.terraform.helpers.resources as r
import input.resource_changes

# METADATA
# title: Deny the creation of Azure DevOps Projects with visibility other than private.
# description: Azure DevOps Projects must have private visibility.
deny contains msg if {
	projects := r.get_resources_by_type("azuredevops_project", resource_changes)
	project := projects[_]
	project.change.after.visibility != "private"
	annotation := rego.metadata.rule()
	msg := annotation.description
}

# METADATA
# title: Deny the creation of Azure DevOps Projects with version control other than Git.
# description: Azure DevOps Projects must use Git for version control.
deny contains msg if {
	projects := r.get_resources_by_type("azuredevops_project", resource_changes)
	project := projects[_]
	project.change.after.version_control != "Git"
	annotation := rego.metadata.rule()
	msg := annotation.description
}

# METADATA
# title: Deny the creation of Azure DevOps Projects with invalid names.
# description: Azure DevOps Project names must be between 4 and 64 characters long, start with a letter, contain only letters, numbers, or hyphens, and not end with a hyphen.
deny contains msg if {
	projects := r.get_resources_by_type("azuredevops_project", resource_changes)
	project := projects[_]
	not has_valid_name(project.change.after.name)
	annotation := rego.metadata.rule()
	msg := annotation.description
}

# METADATA
# title: Check if a string is a valid name.
# description: |
#  A valid name is a string that:
#  - starts with a letter
#  - followed by letters, numbers, or hyphens
#  - does not end with a hyphen
#  - is between 4 and 64 characters long
has_valid_name(name) if {
	regex.match(`^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$`, name)
	count(name) >= 4
	count(name) <= 64
}
