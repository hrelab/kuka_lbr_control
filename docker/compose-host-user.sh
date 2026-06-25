#!/usr/bin/env bash
set -euo pipefail

export USER="${USER:-$(id -un)}"
export USER_UID="${USER_UID:-$(id -u)}"
export USER_GID="${USER_GID:-$(id -g)}"

exec docker compose "$@"
