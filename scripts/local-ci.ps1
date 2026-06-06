#Requires -Version 5.1
param(
    [switch]$LintOnly,
    [switch]$MoleculeOnly,
    [switch]$SkipMolecule,
    [switch]$SkipLint,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

function Show-Usage {
    @"
Run local CI checks before pushing to GitHub.

Usage: scripts/local-ci.ps1 [options]

Options:
  -LintOnly       Run ansible-lint only
  -MoleculeOnly   Run Molecule tests only (requires Docker)
  -SkipMolecule   Skip Molecule integration tests
  -SkipLint       Skip ansible-lint
  -Help           Show this help
"@
}

if ($Help) {
    Show-Usage
    exit 0
}

$RunLint = -not $MoleculeOnly -and -not $SkipLint
$RunSyntax = -not $LintOnly -and -not $MoleculeOnly
$RunMolecule = -not $LintOnly -and -not $SkipMolecule

if ($RunLint) {
    Write-Host "==> ansible-lint"
    if (Get-Command ansible-lint -ErrorAction SilentlyContinue) {
        ansible-lint
    }
    else {
        docker run --rm -v "${Root}:/data" -w /data ghcr.io/ansible/ansible-lint:latest
    }
}

if ($RunSyntax) {
    Write-Host "==> syntax-check ci/playbook.yml"
    if (-not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
        throw "ansible-playbook not found; install ansible or use -LintOnly / -MoleculeOnly"
    }
    ansible-playbook ci/playbook.yml --syntax-check
}

if ($RunMolecule) {
    Write-Host "==> molecule (Linux integration via Docker)"
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Docker is required for Molecule tests. Use -SkipMolecule to continue without it."
    }

    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        wsl bash -lc "cd '$(wsl wslpath -a $Root)' && bash scripts/local-ci.sh --skip-lint"
    }
    elseif (Get-Command molecule -ErrorAction SilentlyContinue) {
        bash run_tests.sh
    }
    else {
        throw "Install WSL or molecule to run Linux integration tests locally."
    }
}

Write-Host "Local CI checks completed successfully."
