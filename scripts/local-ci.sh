#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

run_lint=true
run_molecule=true

usage() {
  cat <<'EOF'
Run local CI checks before pushing to GitHub.

Usage: scripts/local-ci.sh [options]

Options:
  --lint-only       Run ansible-lint only
  --molecule-only   Run Molecule tests only (requires Docker)
  --skip-molecule   Skip Molecule integration tests
  --skip-lint       Skip ansible-lint
  --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lint-only)
      run_molecule=false
      shift
      ;;
    --molecule-only)
      run_lint=false
      shift
      ;;
    --skip-molecule)
      run_molecule=false
      shift
      ;;
    --skip-lint)
      run_lint=false
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

link_role() {
  mkdir -p "${HOME}/.ansible/roles"
  ln -sfn "${ROOT}" "${HOME}/.ansible/roles/riemers.gitlab_runner"
}

if $run_lint; then
  echo "==> ansible-lint"
  link_role
  if command -v ansible-lint >/dev/null 2>&1; then
    ansible-galaxy collection install -r requirements.yml
    ansible-lint
  else
    docker run --rm -v "$ROOT:/data" -w /data python:3.12-slim bash -lc \
      "pip install -q ansible-lint ansible && ansible-galaxy collection install -r requirements.yml && mkdir -p ~/.ansible/roles && ln -sfn /data ~/.ansible/roles/riemers.gitlab_runner && ansible-lint"
  fi
fi

if $run_molecule; then
  echo "==> molecule test"
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required for Molecule tests. Use --skip-molecule to continue without it." >&2
    exit 1
  fi
  if ! command -v molecule >/dev/null 2>&1; then
    echo "molecule not found; run: pip install -r molecule/requirements.txt" >&2
    exit 1
  fi
  link_role
  ansible-galaxy collection install -r requirements.yml
  docker build -t riemers-gitlab-runner-mock molecule/default/mock
  for scenario in default config-update; do
    molecule test -s "$scenario"
  done
fi

echo "Local CI checks completed successfully."
