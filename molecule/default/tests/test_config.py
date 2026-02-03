import os
import pytest
import tomllib
import testinfra.utils.ansible_runner

EXPECTED_ENV = "EXPECTED_TOML"
CONFIG_PATH = "/etc/gitlab-runner/config.toml"
IGNORED_CONFIG_FIELDS = ("token_obtained_at", "token")

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('runner')


def _load_toml_string(content: str):
    return tomllib.loads(content)

def _load_toml_file(path: str):
    with open(path, "rb") as f:
        return tomllib.loads(f.read().decode("utf-8"))

def _normalize(cfg: dict):
    cfg = dict(cfg)  # płytka kopia
    if "runners" in cfg and isinstance(cfg["runners"], list):
        cleaned = []
        for r in cfg["runners"]:
            r = dict(r)
            for k in IGNORED_CONFIG_FIELDS:
                r.pop(k, None)
            cleaned.append(r)
        cfg["runners"] = cleaned
    return cfg

def test_config_matches_expected(host):
    expected_path = os.environ.get(EXPECTED_ENV)
    assert expected_path, f"{EXPECTED_ENV} variable not set"

    f = host.file(CONFIG_PATH)
    assert f.exists, f"{CONFIG_PATH} does not exist on host"
    assert f.is_file, f"{CONFIG_PATH} is not a file"

    got = _normalize(_load_toml_string(f.content_string))
    expected = _normalize(_load_toml_file(expected_path))

    assert got == expected, (
        "config.toml is different than expected\n"
        f"Expected: {expected_path}"
    )
