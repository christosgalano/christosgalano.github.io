# METADATA
# scope: package
# description: A set of helper functions to filter plan resources.

package terraform.helpers.resources

import rego.v1

# METADATA
# title: Get resources by type.
# description: Returns a list of resources of a given type.
get_resources_by_type(type, resources) := filtered_resources if {
	filtered_resources := [resource | resource := resources[_]; resource.type = type]
}

# METADATA
# title: Get resources by action.
# description: Returns a list of resources after filtering by action.
get_resources_by_action(action, resources) := filtered_resources if {
	filtered_resources := [resource | resource := resources[_]; resource.change.actions[_] = action]
}

# METADATA
# title: Get resources by type and action.
# description: Returns a list of resources of a given type and action.
get_resources_by_type_and_action(type, action, resources) := filtered_resources if {
	filtered_resources := [resource | resource := resources[_]; resource.type = type; resource.change.actions[_] = action]
}

# METADATA
# title: Get resources by name.
# description: Returns a list of resources of a given name.
get_resource_by_name(resource_name, resources) := filtered_resources if {
	filtered_resources := [resource | resource := resources[_]; resource.name = resource_name]
}

# METADATA
# title: Get resources by type and name.
# description: Returns a list of resources of a given type and name.
get_resource_by_type_and_name(type, resource_name, resources) := filtered_resources if {
	filtered_resources := [resource | resource := resources[_]; resource.type = type; resource.name = resource_name]
}
