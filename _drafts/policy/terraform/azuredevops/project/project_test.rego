package terraform.azuredevops.project

import rego.v1

# Test that a project with private visibility is allowed
test_private_visibility if {
	count(deny) == 0 with input as {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"visibility": "private"}}}]}
}

# Test that a project with visibility other than private is not allowed
test_public_visibility if {
	count(deny) > 0 with input as {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"visibility": "public"}}}]}
}

# Test that the visibility deny message is correct
test_visibility_deny_msg if {
	msg := deny with input as {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"visibility": "public"}}}]}
	msg == {"Azure DevOps Projects must have private visibility."}
}

# Test that a project with version control Git is allowed
test_git_version_control if {
	count(deny) == 0 with input as {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"version_control": "Git"}}}]}
}

# Test that a project with version control other than Git is not allowed
test_tfvc_version_control if {
	count(deny) > 0 with input as {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"version_control": "TFVC"}}}]}
}

# Test that the version control deny message is correct
test_version_control_deny_msg if {
	msg := deny with input as {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"version_control": "TFVC"}}}]}
	msg == {"Azure DevOps Projects must use Git for version control."}
}

# Helper function to generate the input object
input_with_name(name) := {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"name": name}}}]}

# Test that a project with a valid name is allowed
test_valid_project_name if {
	count(deny) == 0 with input as input_with_name("Valid-Project-Name")
}

# Test that a project name that starts with a number is not allowed
test_project_name_starts_with_number if {
	count(deny) > 0 with input as input_with_name("1invalid-project")
}

# Test that a project name that ends with a hyphen is not allowed
test_project_name_ends_with_hyphen if {
	count(deny) > 0 with input as input_with_name("INVALID-project-")
}

# Test that a project name with invalid characters is not allowed
test_project_name_contains_invalid_characters if {
	count(deny) > 0 with input as input_with_name("invalid_project")
}

# Test that a project name that is too short is not allowed
test_short_project_name if {
	count(deny) > 0 with input as input_with_name("inv")
}

# Test that a project name that is too long is not allowed
test_long_project_name if {
	count(deny) > 0 with input as input_with_name("invalid-project-invalid-project-invalid-project-invalid-project-invalid-project-invalid-project-invalid")
}

# Test that the name deny message is correct
test_name_deny_msg if {
	msg := deny with input as {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"name": "invalid name"}}}]}
	msg == {"Azure DevOps Project names must be between 4 and 64 characters long, start with a letter, contain only letters, numbers, or hyphens, and not end with a hyphen."}
}

# Test that a project with public visibility, SVN version control, and an invalid name is denied with the correct messages
test_all_conditions if {
	# Collect all deny messages
	msgs := {msg | deny[msg] with input as {"resource_changes": [{"type": "azuredevops_project", "change": {"after": {"visibility": "public", "version_control": "SVN", "name": "Invalid-Name-"}}}]}}

	# Check that the deny rule returns the correct set of messages
	msgs == {
		"Azure DevOps Projects must have private visibility.",
		"Azure DevOps Projects must use Git for version control.",
		"Azure DevOps Project names must be between 4 and 64 characters long, start with a letter, contain only letters, numbers, or hyphens, and not end with a hyphen.",
	}
}
