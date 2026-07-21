#!/usr/bin/env bats

# Each BATS test runs in its own subshell, so these assignments do not leak.
# shellcheck disable=SC2030,SC2031

setup() {
  load "${BATS_PLUGIN_PATH}/load.bash"
  export BUILDKITE_JOB_ID="test-job"
}

@test "pre-command exports the latest coredump checksum" {
  stub coredumpctl \
    '--no-pager --quiet --json=short -1 list : echo before'

  run bash -c '. "$1"; printf "checksum=%s\n" "$COREDUMP_LAST_CKSUM"' \
    _ "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Storing checksum"
  assert_output --regexp 'checksum=[0-9]+ [0-9]+'

  unstub coredumpctl
}

@test "post-command does nothing when the latest coredump is unchanged" {
  export COREDUMP_LAST_CKSUM
  COREDUMP_LAST_CKSUM=$(printf 'same\n' | cksum)

  stub coredumpctl \
    '--no-pager --quiet --json=short -1 list : echo same'

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "unchanged since pre-command"
  refute_output --partial "artifact upload"

  unstub coredumpctl
}

@test "post-command uploads a newly generated coredump" {
  export COREDUMP_LAST_CKSUM
  COREDUMP_LAST_CKSUM=$(printf 'before\n' | cksum)

  stub coredumpctl \
    '--no-pager --quiet --json=short -1 list : echo after' \
    '--no-pager --quiet -1 dump : echo core-dump'
  stub xz \
    ': cat'
  stub buildkite-agent \
    'artifact upload test-job.core.xz : echo artifact uploaded'

  run bash -c 'cd "$1" && "$2"' \
    _ "$BATS_TEST_TMPDIR" "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Latest accessible coredump changed"
  assert_output --partial "artifact uploaded"
  assert_file_exists "$BATS_TEST_TMPDIR/test-job.core.xz"

  unstub coredumpctl
  unstub xz
  unstub buildkite-agent
}

@test "post-command fails when pre-command state is missing" {
  unset COREDUMP_LAST_CKSUM

  stub coredumpctl

  run "$PWD/hooks/post-command"

  assert_failure 1
  assert_output --partial "expected it to be exported by pre-command"

  unstub coredumpctl
}
