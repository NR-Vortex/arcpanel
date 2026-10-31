#!/usr/bin/env bats
# Tests for read-only system list commands.
# Run as root on a server installed with the ArcPanel installer.

if [ "${PATH#*/usr/local/arcpanel/bin*}" = "$PATH" ]; then
	. /etc/profile.d/arcpanel.sh
fi

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

@test "v-get-sys-timezones returns sorted timezone paths in JSON" {
	run v-get-sys-timezones json
	assert_success

	assert_equal "$(jq -r 'type' <<< "$output")" "array"
	assert_equal "$(jq -r 'length' <<< "$output")" "$(find -L /usr/share/zoneinfo -mindepth 1 -type f -o -type l | sed 's#^/usr/share/zoneinfo/##' | sort | wc -l)"
	assert_equal "$(jq -r '.[0]' <<< "$output")" "$(jq -r '.[0]' <<< "$(v-get-sys-timezones json)")"
	assert_equal "$(jq -r '.[0]' <<< "$output")" "$(find -L /usr/share/zoneinfo -mindepth 1 -type f -o -type l | sed 's#^/usr/share/zoneinfo/##' | sort | head -n1)"
}

@test "v-get-sys-timezones plain output matches JSON output" {
	run v-get-sys-timezones plain
	assert_success

	assert_equal "$(printf '%s\n' "$output" | wc -l)" "$(v-get-sys-timezones json | jq 'length')"
	assert_equal "$(printf '%s\n' "$output" | head -n1)" "$(v-get-sys-timezones json | jq -r '.[0]')"
}

@test "v-get-sys-timezones shell output has the expected header" {
	run v-get-sys-timezones shell
	assert_success
	assert_line --index 0 'Timezone'
	assert_line --index 1 '--------'
}
