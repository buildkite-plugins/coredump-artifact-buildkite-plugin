#!/bin/bash

# Shared utility functions for Buildkite plugins.

set -euo pipefail

log_info() {
  echo "[INFO]: $*"
}

log_success() {
  echo "[SUCCESS]: $*"
}

log_warning() {
  echo "[WARNING]: $*"
}

log_error() {
  echo "[ERROR]: $*" >&2
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

is_debug_mode() {
  [[ "${BUILDKITE_PLUGIN_DEBUG:-false}" =~ (true|on|1) ]]
}

setup_error_trap() {
  trap 'log_error "Command failed with exit status $? at line $LINENO: $BASH_COMMAND"' ERR
}

enable_debug_if_requested() {
  if is_debug_mode; then
    log_info "Debug mode enabled"
    set -x
  fi
}
