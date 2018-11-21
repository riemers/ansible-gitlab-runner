GitLab Runner [![Build Status](https://api.travis-ci.org/riemers/ansible-gitlab-runner.svg?branch=master)](https://travis-ci.org/riemers/ansible-gitlab-runner) [![Ansible Role](https://img.shields.io/badge/role-riemers.gitlab--runner-blue.svg?maxAge=2592000)](https://galaxy.ansible.com/riemers/gitlab-runner/)
=============

This role will install the [official GitLab Runner](https://gitlab.com/gitlab-org/gitlab-runner)
(fork from haroldb) with updates. Needed something simple and working, this did the trick for me. Open for changes though.

Requirements
------------

This role requires Ansible 2.0 or higher.

Role Variables
--------------

`gitlab_runner_package_name`
**Since Gitlab 10.x** The package name of `gitlab-ci-multi-runner` has been renamed to `gitlab-runner`. In order to install a version >= 10.x you will need to define this variable `gitlab_runner_package_name: gitlab-runner`.

`gitlab_runner_concurrent`
The maximum number of global jobs to run concurrently.
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

`gitlab_runner_concurrent_specific`
The maximum number of jobs to run concurrently on this specific runner.
Defaults to 0, simply means don't limit.

`gitlab_runner_docker_image`
The default Docker image to use. Required when executor is `docker`.

`gitlab_runner_tags`
The tags assigned to the runner,
Defaults to an empty list.

`gitlab_runner_cache_type`
Variables to set s3 as a shared cache server. If set it requires variables listed below:
`gitlab_runner_cache_s3_server_address`
`gitlab_runner_cache_s3_access_key`
`gitlab_runner_cache_s3_access_key`
`gitlab_runner_cache_s3_bucket_name`
`gitlab_runner_cache_s3_insecure`
`gitlab_runner_cache_cache_shared`

See the [config for more options](https://github.com/riemers/ansible-gitlab-runner/blob/master/tasks/register-runner.yml)

Example Playbook
----------------
Inside `gitlab-runner.yaml`
```yaml
- hosts: gitlab-runner
  become: yes
  roles:
    - { role: riemers.gitlab-runner }
  vars_files: myvars.yaml
```

Example Inventory
```
[gitlab-runner]
gitlab-runner1 ansible_host=192.168.0.1
```

Inside `myvars.yaml`
```yaml
proxy_env:
  http_proxy: http://proxy-squid:3128
  https_proxy: http://proxy-squid:3128
  no_proxy: 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
gitlab_runner_coordinator_url: 'gitlab ci url'
gitlab_runner_registration_token: 'gitlab token'
```

Inside `host_vars/gitlab-runner1.yml`
```yaml
gitlab_runner_executor: shell
gitlab_runner_description: 'Example Gitlab Runner'
gitlab_runner_tags:
  - node
  - ruby
  - mysql
gitlab_runner_docker_volumes:
  - "/var/run/docker.sock:/var/run/docker.sock"
  - "/cache"
```
