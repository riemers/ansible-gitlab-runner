#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "${HOME}/.ansible/roles"
ln -sfn "${ROOT}" "${HOME}/.ansible/roles/riemers.gitlab_runner"
