# METADATA
# scope: package
# description: A set of helper functions to work with resource tags.

package terraform.helpers.tags

import rego.v1

# METADATA
# title: Get tags from a given resource.
# description: Return the tags of a given resource.
get_tags(resource) := tags if {
	tags = resource.change.after.tags
}

# METADATA
# title: Check if tag is present for a given resource.
# description: Return true if tag is present, otherwise false.
check_tag_existence(resource, tag_name) if {
	get_tags(resource)[tag_name]
}

# METADATA
# title: Check if a tag has a specific value for a given resource.
# description: Return true if tag has a specific value, otherwise false.
check_tag_value(resource, tag_name, tag_value) if {
	get_tags(resource)[tag_name] == tag_value
}

# METADATA
# title: Check if there are missing tags.
# description: Return true if there are missing tags, otherwise false.
check_missing_tags(resource, tag_list) if {
	keys := {key | resource.change.after.tags[key]}
	missing := tag_list - keys
	missing == set()
}
