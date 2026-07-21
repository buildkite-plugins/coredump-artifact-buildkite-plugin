# Coredump Artifact Upload Buildkite Plugin

A Buildkite plugin that detects core dumps generated while a job is running and uploads them as an artifact.

The plugin records the most recent systemd coredump before the command runs. If the most recent coredump changes during the command, it compresses that dump with `xz` and uploads it as `<job-id>.core.xz`.

> [!WARNING]
> This plugin is not designed for hosts running multiple Buildkite agents, including agents started with `--spawn`. Because the systemd coredump journal is shared by the host, a dump from another job may be uploaded to the wrong job.

## Requirements

- A Linux host using `systemd-coredump`
- `bash`, `coredumpctl`, `cksum`, and `xz` available on `PATH`
- Permission for the Buildkite agent user to read coredumps

If `coredumpctl` is unavailable, the plugin logs a warning and does nothing.

## Configuration

This plugin does not accept configuration options.

## Example

```yaml
steps:
  - label: ":hammer: Run crash test"
    command: "./run-crash-test"
    plugins:
      - buildkite-plugins/coredump-artifact#v1.0.0: ~
```

## Compatibility

| Elastic Stack | Agent Stack K8s | Hosted (Mac) | Hosted (Linux) | Notes |
| :-----------: | :-------------: | :----------: | :------------: | :---- |
|      ⚠️       |       ❌        |      ❌      |       ⚠️       | Requires a Linux host using `systemd-coredump`. |

- ✅ Fully supported
- ⚠️ Supported only when the requirements above are met
- ❌ Not supported

## Developing

Run the tests:

```bash
docker run --rm -v "$PWD:/plugin:ro" buildkite/plugin-tester
```

Validate the plugin metadata and README examples:

```bash
docker run --rm -v "$PWD:/plugin:ro" buildkite/plugin-linter \
  --id buildkite-plugins/coredump-artifact --path /plugin
```

Run static analysis:

```bash
shellcheck hooks/* tests/* lib/*.bash
```

See [DEVELOPMENT.md](DEVELOPMENT.md) for implementation guidance.

## Contributing

1. Fork the repository.
2. Make your changes and add or update tests.
3. Run the tests, plugin linter, and ShellCheck checks above.
4. Open a pull request.

## License

The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
