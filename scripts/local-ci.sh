#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

run_lint=true
run_molecule=true
run_syntax=true

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
      run_syntax=false
      shift
      ;;
    --molecule-only)
      run_lint=false
      run_syntax=false
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

if $run_lint; then
  echo "==> ansible-lint"
  if command -v ansible-lint >/dev/null 2>&1; then
    ansible-lint
  else
    docker run --rm -v "$ROOT:/data" -w /data ghcr.io/ansible/ansible-lint:latest
  fi
fi

if $run_syntax; then
  echo "==> syntax-check ci/playbook.yml"
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "ansible-playbook not found; install ansible or use --lint-only / --molecule-only" >&2
    exit 1
  fi
  ansible-playbook ci/playbook.yml --syntax-check
fi

if $run_molecule; then
  echo "==> molecule (Linux integration)"
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required for Molecule tests. Use --skip-molecule to continue without it." >&2
    exit 1
  fi
  if ! command -v molecule >/dev/null 2>&1; then
    echo "molecule not found; run: pip install -r molecule/requirements.txt" >&2
    exit 1
  fi
  bash run_tests.sh
fi

echo "Local CI checks completed successfully."
