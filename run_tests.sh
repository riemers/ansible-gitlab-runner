#!/usr/bin/env bash
set -euox pipefail

molecule create


TEST_VARS_FILE=vars/initial.yml molecule converge
EXPECTED_TOML=expected/initial.toml molecule verify

TEST_VARS_FILE=vars/updated.yml molecule converge
EXPECTED_TOML=expected/updated.toml molecule verify

molecule destroy
