# Plugin development guide

This plugin follows the conventions in the current [Buildkite plugin template](https://github.com/buildkite-plugins/template-buildkite-plugin).

## Structure

- `hooks/pre-command` records the checksum of the latest accessible coredump.
- `hooks/post-command` compares the latest checksum, dumps a new core, compresses it, and uploads it.
- `lib/shared.bash` contains the logging, error reporting, and debug helpers shared by both hooks.
- `tests/hooks.bats` tests both hooks with the Buildkite plugin tester.

Keep hook logic in the hook files while the plugin remains small. Add modules only if logic is shared or a hook grows substantially.

## Hook conventions

- Use Bash strict mode: `set -euo pipefail`.
- Set up the shared error trap near the start of each hook.
- Support debug logging through `BUILDKITE_PLUGIN_DEBUG=true`.
- Resolve required commands through `PATH` rather than hard-coded filesystem paths.
- Quote variable expansions and avoid printing potentially sensitive environment values.

The Buildkite agent propagates exported environment changes between hooks. `pre-command` therefore exports `COREDUMP_LAST_CKSUM` for `post-command`.

## Testing

Use the commands in [README.md](README.md#developing) to run BATS, the plugin linter, and ShellCheck. Tests should cover both the unchanged-coredump path and artifact upload path, and should use command stubs rather than requiring system coredumps.
