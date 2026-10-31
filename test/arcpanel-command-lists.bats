#!/usr/bin/env bats
# Tests for read-only system list commands.
# Run as root on a server installed with the ArcPanel installer.

if [ "${PATH#*/usr/local/arcpanel/bin*}" = "$PATH" ]; then
	. /etc/profile.d/arcpanel.sh
fi

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

@test "v-list-sys-shells supports plain, JSON, and shell formats" {
	run v-list-sys-shells json
	assert_success
	assert_equal "$(jq -r 'type' <<< "$output")" "array"
	assert_equal "$(jq -r 'length' <<< "$output")" "$(v-list-sys-shells plain | wc -l)"
	assert_equal "$(jq -r '.[0]' <<< "$output")" "$(v-list-sys-shells plain | head -n1)"

	run v-list-sys-shells shell
	assert_success
	assert_line --index 0 'SHELL'
	assert_line --index 1 '-----'
}

@test "v-list-sys-shells plain output is unique and sorted" {
	run v-list-sys-shells plain
	assert_success
	assert_equal "$(printf '%s\n' "$output" | sort -u)" "$output"
	assert_equal "$(printf '%s\n' "$output" | sort)" "$output"
}

@test "v-list-sys-database-types supports plain, JSON, and shell formats" {
	run v-list-database-types json
	assert_success
	assert_equal "$(jq -r 'type' <<< "$output")" "array"
	assert_equal "$(jq -r 'length' <<< "$output")" "$(v-list-database-types plain | wc -l)"
	assert_equal "$(jq -r '.[0]' <<< "$output")" "$(v-list-database-types plain | head -n1)"

	run v-list-database-types shell
	assert_success
	assert_line --index 0 'TYPE'
	assert_line --index 1 '----'
}
