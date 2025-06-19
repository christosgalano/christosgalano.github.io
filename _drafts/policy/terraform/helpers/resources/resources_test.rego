package terraform.helpers.resources

import rego.v1

# Test that get_resources_by_type returns the correct resources
test_get_resources_by_type if {
	resources := [{"type": "type1", "name": "name1"}, {"type": "type2", "name": "name2"}]
	get_resources_by_type("type1", resources) == [{"type": "type1", "name": "name1"}]
}

# Test that get_resources_by_action returns the correct resources
test_get_resources_by_action if {
	resources := [{"type": "type1", "name": "name1", "change": {"actions": ["create"]}}, {"type": "type2", "name": "name2", "change": {"actions": ["delete"]}}]
	get_resources_by_action("create", resources) == [{"type": "type1", "name": "name1", "change": {"actions": ["create"]}}]
}

# Test that get_resources_by_type_and_action returns the correct resources
test_get_resources_by_type_and_action if {
	resources := [{"type": "type1", "name": "name1", "change": {"actions": ["create"]}}, {"type": "type2", "name": "name2", "change": {"actions": ["delete"]}}]
	get_resources_by_type_and_action("type1", "create", resources) == [{"type": "type1", "name": "name1", "change": {"actions": ["create"]}}]
}

# Test that get_resource_by_name returns the correct resources
test_get_resource_by_name if {
	resources := [{"type": "type1", "name": "name1"}, {"type": "type2", "name": "name2"}]
	get_resource_by_name("name1", resources) == [{"type": "type1", "name": "name1"}]
}

# Test that get_resource_by_type_and_name returns the correct resources
test_get_resource_by_type_and_name if {
	resources := [{"type": "type1", "name": "name1"}, {"type": "type2", "name": "name2"}]
	get_resource_by_type_and_name("type1", "name1", resources) == [{"type": "type1", "name": "name1"}]
}
