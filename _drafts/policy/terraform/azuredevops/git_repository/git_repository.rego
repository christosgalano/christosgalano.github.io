# METADATA
# scope: package
# description: A set of rules to enforce constraints on Azure DevOps Git Repositories.

package terraform.azuredevops.git_repository

import rego.v1

import input as tfplan

# METADATA
# title: Deny the creation of Azure DevOps Repositories with invalid names.
# description: Azure DevOps Repository names must be between 4 and 64 characters long, start with a letter, contain only letters, numbers, or hyphens, and not end with a hyphen.
deny contains msg if {
	r := tfplan.resource_changes[_]
	r.type == "azuredevops_git_repository"

	not has_valid_name(r.change.after.name)

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
