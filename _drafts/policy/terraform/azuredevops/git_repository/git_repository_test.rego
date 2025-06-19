package terraform.azuredevops.git_repository

import rego.v1

# Helper function to generate the input object
input_with_name(name) := {"resource_changes": [{"type": "azuredevops_git_repository", "change": {"after": {"name": name}}}]}

# Test that a repository with a valid name is allowed
test_valid_repository_name if {
	count(deny) == 0 with input as input_with_name("VALID-template-repo")
}

# Test that a repository name that starts with a number is not allowed
test_repository_name_starts_with_number if {
	count(deny) > 0 with input as input_with_name("1invalid-repo")
}

# Test that a repository name that ends with a hyphen is not allowed
test_repository_name_ends_with_hyphen if {
	count(deny) > 0 with input as input_with_name("INVALID-repo-")
}

# Test that a repository name with invalid characters is not allowed
test_repository_name_contains_invalid_characters if {
	count(deny) > 0 with input as input_with_name("invalid repo")
}

# Test that a repository name that is too short is not allowed
test_short_repository_name if {
	count(deny) > 0 with input as input_with_name("inv")
}

# Test that a repository name that is too long is not allowed
test_long_repository_name if {
	count(deny) > 0 with input as input_with_name("invalid-repository-invalid-repository-invalid-repository-invalid-repository-invalid-repository-invalid")
}

# Test that the name deny message is correct
test_name_deny_message if {
	msg := deny with input as input_with_name("invalid () repository")
	msg == {"Azure DevOps Repository names must be between 4 and 64 characters long, start with a letter, contain only letters, numbers, or hyphens, and not end with a hyphen."}
}
