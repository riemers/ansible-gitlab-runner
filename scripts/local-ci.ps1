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
  -MoleculeOnly   Run Molecule tests only (requires Docker + WSL/Linux)
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
$RunMolecule = -not $LintOnly -and -not $SkipMolecule

if ($RunLint) {
    Write-Host "==> ansible-lint (Docker)"
    docker run --rm -v "${Root}:/data" -w /data python:3.12-slim bash -lc "pip install -q ansible-lint ansible && ansible-galaxy collection install -r requirements.yml && mkdir -p ~/.ansible/roles && ln -sfn /data ~/.ansible/roles/riemers.gitlab_runner && ansible-lint"
}

if ($RunMolecule) {
    Write-Host "==> molecule test (via WSL/Linux + Docker)"
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Docker is required for Molecule tests. Use -SkipMolecule to continue without it."
    }
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        wsl bash -lc "cd '$(wsl wslpath -a $Root)' && bash scripts/local-ci.sh --skip-lint"
    }
    else {
        throw "Install WSL to run Molecule locally on Windows, or use -SkipMolecule."
    }
}

Write-Host "Local CI checks completed successfully."
