GitLab Runner [![Build Status](https://api.travis-ci.org/riemers/ansible-gitlab-runner.svg?branch=master)](https://travis-ci.org/riemers/ansible-gitlab-runner) [![Ansible Role](https://img.shields.io/badge/role-riemers.gitlab--runner-blue.svg?maxAge=2592000)](https://galaxy.ansible.com/riemers/gitlab-runner/)
=============

This role will install the [official GitLab Runner](https://gitlab.com/gitlab-org/gitlab-runner)
(fork from haroldb) with updates. Needed something simple and working, this did the trick for me. Open for changes though.

Requirements
------------

This role requires Ansible 2.7 or higher.

Role Variables
--------------

`gitlab_runner_package_name`
**Since Gitlab 10.x** The package name of `gitlab-ci-multi-runner` has been renamed to `gitlab-runner`. In order to install a version < 10.x you will need to define this variable `gitlab_runner_package_name: gitlab-ci-multi-runner`.

`gitlab_runner_wanted_version` or `gitlab_runner_package_version`
To install a specific version of the gitlab runner (by default it installs the latest).
On Mac OSX and Windows, use e.g. `gitlab_runner_wanted_version: 12.4.1`.
On Linux, use `gitlab_runner_package_version` instead.

`gitlab_runner_concurrent`
The maximum number of global jobs to run concurrently.
Defaults to the number of processor cores.

`gitlab_runner_registration_token`
The GitLab registration token. If this is specified, a runner will be registered to a GitLab server.

`gitlab_runner_coordinator_url`
The GitLab coordinator URL.
Defaults to `https://gitlab.com/ci`.

`gitlab_runner_sentry_dsn`
Enable tracking of all system level errors to Sentry

`gitlab_runner_listen_address`
Enable `/metrics` endpoint for Prometheus scraping.

`gitlab_runner_runners`
A list of gitlab runners to register & configure. Defaults to a single shell executor. See the [`defaults/main.yml`](https://github.com/riemers/ansible-gitlab-runner/blob/master/defaults/main.yml) file listing all possible options which you can be passed to a runner registration command.

`gitlab_runner_cache_type`
Variables to set s3 as a shared cache server. If set it requires variables listed below:
`gitlab_runner_cache_s3_server_address`
`gitlab_runner_cache_s3_access_key`
`gitlab_runner_cache_s3_access_key`
`gitlab_runner_cache_s3_bucket_name`
`gitlab_runner_cache_s3_bucket_location`
`gitlab_runner_cache_s3_insecure`
`gitlab_runner_cache_cache_shared`

aws autoscale runner machine
https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/#the-runnersmachine-section

    gitlab_runner_machine_options: []

https://docs.docker.com/machine/drivers/aws/#options

    gitlab_runner_machine_idle_count: ''
    gitlab_runner_machine_idle_time: ''
    gitlab_runner_machine_max_builds: ''

https://docs.gitlab.com/runner/configuration/autoscale.html#how-concurrent-limit-and-idlecount-generate-the-upper-limit-of-running-machines

    gitlab_runner_machine_off_peak_periods: ''
    gitlab_runner_machine_off_peak_idle_time: ''
    gitlab_runner_machine_off_peak_idle_count: ''

https://docs.gitlab.com/runner/configuration/autoscale.html#off-peak-time-mode-configuration

    gitlab_runner_machine_machine_driver: 'amazonec2'
    gitlab_runner_machine_machine_name: 'gitlab-docker-machine-%s'

The Docker Machine driver is set to amazonec2 and the machine name has a standard prefix followed by %s (required) that is replaced by the ID of the child Runner: gitlab-docker-machine-%s.

See the [config for more options](https://github.com/riemers/ansible-gitlab-runner/blob/master/tasks/register-runner.yml)

Example Playbook
----------------
```yaml
- hosts: all
  remote_user: root
  vars_files:
    - vars/main.yml
  roles:
    - { role: riemers.gitlab-runner }
```

Inside `vars/main.yml`
```yaml
gitlab_runner_registration_token: 'HUzTMgnxk17YV8Rj8ucQ'
gitlab_runner_runners:
  - name: 'Example Docker GitLab Runner'
    # token is an optional override to the global gitlab_runner_registration_token
    token: 'HUzTMgnxk17YV8Rj8ucQ'
    executor: docker
    docker_image: 'alpine'
    tags:
      - node
      - ruby
      - mysql
    docker_volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "/cache"
    extra_configs:
      runners.docker:
        memory: 512m
        allowed_images: ["ruby:*", "python:*", "php:*"]
      runners.docker.sysctls:
        net.ipv4.ip_forward: "1"
```

Contributors
------------
Feel free to add your name to the readme if you make a PR. A full list of people from the PR's is [here](https://github.com/riemers/ansible-gitlab-runner/pulls?q=is%3Apr+is%3Aclosed)

- Gastrofix for adding Mac Support
- Matthias Schmieder for adding Windows Support
