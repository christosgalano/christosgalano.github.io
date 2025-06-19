package terraform.helpers.tags

import rego.v1

# Test that get_tags returns the tags of a resource
test_get_tags if {
	tags := get_tags({"change": {"after": {"tags": {"tag1": "value1", "tag2": "value2"}}}})
	tags == {"tag1": "value1", "tag2": "value2"}
}

# Test that check_tag_existence returns true if the tag exists
test_check_tag_existence_exists if {
	check_tag_existence({"change": {"after": {"tags": {"tag1": "value1", "tag2": "value2"}}}}, "tag1")
}

# Test that check_tag_existence returns false if the tag does not exist
test_check_tag_existence_not_exists if {
	not check_tag_existence({"change": {"after": {"tags": {"tag1": "value1", "tag2": "value2"}}}}, "tag3")
}

# Test that check_tag_value returns true if the tag has the correct value
test_check_tag_value_correct if {
	check_tag_value({"change": {"after": {"tags": {"tag1": "value1", "tag2": "value2"}}}}, "tag1", "value1")
}

# Test that check_tag_value returns false if the tag has the wrong value
test_check_tag_value_wrong if {
	not check_tag_value({"change": {"after": {"tags": {"tag1": "value1", "tag2": "value2"}}}}, "tag1", "value2")
}

# Test that check_missing_tags returns true if all tags are present
test_check_missing_tags_present if {
	check_missing_tags({"change": {"after": {"tags": {"tag1": "value1", "tag2": "value2"}}}}, {"tag1", "tag2"})
}

# Test that check_missing_tags returns false if some tags are missing
test_check_missing_tags_missing if {
	not check_missing_tags({"change": {"after": {"tags": {"tag1": "value1", "tag2": "value2"}}}}, {"tag1", "tag2", "tag3"})
}
