GitLab Runner
=============

This role will install the [official GitLab Runner](https://gitlab.com/gitlab-org/gitlab-ci-multi-runner)
(fork from haroldb) with updates. Needed something simple and working, this did the trick for me. Open for changes though.

Requirements
------------

This role requires Ansible 2.0 or higher.

Role Variables
--------------

`gitlab_runner_concurrent`
The maximum number of jobs to run concurrently.
Defaults to the number of processor cores.

`gitlab_runner_registration_token`
The GitLab registration token. If this is specified, a runner will be registered to a GitLab server.

`gitlab_runner_coordinator_url`
The GitLab coordinator URL.
Defaults to `https://gitlab.com/ci`.

`gitlab_runner_description`
The description of the runner.
Defaults to the hostname.

`gitlab_runner_executor`
The executor used by the runner.
Defaults to `shell`.

`gitlab_runner_docker_image`
The default Docker image to use. Required when executor is `docker`.

`gitlab_runner_tags`
The tags assigned to the runner,
Defaults to an empty list.

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
gitlab_runner_description: 'Example GitLab Runner'
gitlab_runner_tags:
  - node
  - ruby
  - mysql
gitlab_runner_docker_volumes:
  - "/var/run/docker.sock:/var/run/docker.sock"
  - "/cache"
```
