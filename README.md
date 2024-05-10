GitLab Runner [![Build Status](https://app.travis-ci.com/riemers/ansible-gitlab-runner.svg?branch=master)](https://travis-ci.org/riemers/ansible-gitlab-runner) [![Ansible Role](https://img.shields.io/badge/role-riemers.gitlab--runner-blue.svg?maxAge=2592000)](https://galaxy.ansible.com/ui/standalone/roles/riemers/gitlab-runner/)
=============

This role will install the [official GitLab Runner](https://gitlab.com/gitlab-org/gitlab-runner)
(fork from haroldb) with updates. Needed something simple and working, this did the trick for me. Open for changes though.

Requirements
------------

This role requires Ansible 2.13 or higher.

Role Variables
--------------

- `gitlab_runner_package_name` - **Since Gitlab 10.x** The package name of `gitlab-ci-multi-runner` has been renamed to `gitlab-runner`. In order to install a version < 10.x you will need to define this variable `gitlab_runner_package_name: gitlab-ci-multi-runner`.
- `gitlab_runner_wanted_version` or `gitlab_runner_package_version` - To install a specific version of the gitlab runner (by default it installs the latest).
On Mac OSX and Windows, use e.g. `gitlab_runner_wanted_version: 12.4.1`.
On Linux, use `gitlab_runner_package_version` instead.
- `gitlab_runner_concurrent` - The maximum number of global jobs to run concurrently. Defaults to the number of processor cores.
- `gitlab_runner_registration_token` - The GitLab registration token. If this is specified, a runner will be registered to a GitLab server.
- `gitlab_runner_coordinator_url` - The GitLab coordinator URL. Defaults to `https://gitlab.com`.
- `gitlab_runner_sentry_dsn` - Enable tracking of all system level errors to Sentry
- `gitlab_runner_listen_address` - Enable `/metrics` endpoint for Prometheus scraping.
- `gitlab_runner_runners` - A list of gitlab runners to register & configure. Defaults to a single shell executor.
- `gitlab_runner_skip_package_repo_install`- Skip the APT or YUM repository installation (by default, false). You should provide a repository containing the needed packages before running this role.
- `gitlab_runner_config_update_mode`- Set to `by_config_toml` (default) if this role should apply config changes by updating the `config.toml` itself or set it to `by_registering` if config changes should be applied by unregistering and regeistering the runner in case the config has changed.
- `gitlab_unregister_runner_executors_which_are_not_longer_configured` - Set to `true` if executors should be unregistered from a runner in case it is are not longer configured in ansible. Default: `false`

See the [`defaults/main.yml`](https://github.com/riemers/ansible-gitlab-runner/blob/master/defaults/main.yml) file listing all possible options which you can be passed to a runner registration command.

### Gitlab Runners cache
For each gitlab runner in gitlab_runner_runners you can set cache options. At the moment role support s3, azure and gcs types.
Example configurration for s3 can be:
```yaml
gitlab_runner:
  cache_type: "s3"
  cache_path: "cache"
  cache_shared: true
  cache_s3_server_address: "s3.amazonaws.com"
  cache_s3_access_key: "<access_key>"
  cache_s3_secret_key: "<secret_key>"
  cache_s3_bucket_name: "<bucket_name>"
  cache_s3_bucket_location: "eu-west-1"
  cache_s3_insecure: false
```

## Autoscale Runner Machine vars for AWS (optional)

- `MachineOptions: []` - Foremost you need to pass an array of dedicated vars in the machine_options to configure your scaling runner:

  + `amazonec2-access-key` and `amazonec2-secret-key` the keys of the dedicated IAM user with permission for EC2
  + `amazonec2-zone`
  + `amazonec2-region`
  + `amazonec2-vpc-id`
  + `amazonec2-subnet-id`
  + `amazonec2-use-private-address=true`
  + `amazonec2-security-group`
  + `amazonec2-instance-type`
  + you can also set `amazonec2-tags` to identify you instance more easily via aws-cli or the console.

- `MachineDriver` - which should be set to `amzonec2` when working on AWS
- `MachineName` - Name of the machine. It **must** contain `%s`, which will be replaced with a unique machine identifier.
- `IdleCount` - Number of machines, that need to be created and waiting in Idle state.
- `IdleTime` - Time (in seconds) for machine to be in Idle state before it is removed.
- `MaxGrowthRate` - The maximum number of machines that can be added to the runner in parallel. Default is 0 (no limit).
- `MaxBuilds` - Maximum job (build) count before machine is removed.
- `IdleScaleFactor` - (Experimental) The number of Idle machines as a factor of the number of machines currently in use. Must be in float number format. See the autoscale documentation for more details. Defaults to 0.0.
- `IdleCountMin` - 	Minimal number of machines that need to be created and waiting in Idle state when the IdleScaleFactor is in use. Default is 1.

### Read Sources
For details follow these links:

- [gitlab-docs/runner: advanced configuration: runners.machine section](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachine-section)
- [gitlab-docs/runner: autoscale: supported cloud-providers](https://docs.gitlab.com/runner/configuration/autoscale.html#supported-cloud-providers)
- [gitlab-docs/runner: autoscale_aws: runners.machine section](https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/#the-runnersmachine-section)

See the [config for more options](https://github.com/riemers/ansible-gitlab-runner/blob/master/tasks/register-runner.yml)

Example Playbook
----------------
```yaml
- hosts: all
  become: true
  vars_files:
    - vars/main.yml
  roles:
    - { role: riemers.gitlab-runner }
```

Inside `vars/main.yml`
```yaml
gitlab_runner_coordinator_url: https://gitlab.com
gitlab_runner_registration_token: '12341234'
gitlab_runner_runners:
  - name: 'Example Docker GitLab Runner'
    # token is an optional override to the global gitlab_runner_registration_token
    token: 'abcd'
    # url is an optional override to the global gitlab_runner_coordinator_url
    url: 'https://my-own-gitlab.mydomain.com'
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

## autoscale setup on AWS
how `vars/main.yml` would look like, if you setup an autoscaling GitLab-Runner on AWS:

```yaml
gitlab_runner_registration_token: 'HUzTMgnxk17YV8Rj8ucQ'
gitlab_runner_coordinator_url: 'https://gitlab.com'
gitlab_runner_runners:
  - name: 'Example autoscaling GitLab Runner'
    state: present
    # token is an optional override to the global gitlab_runner_registration_token
    token: 'HUzTMgnxk17YV8Rj8ucQ'
    executor: 'docker+machine'
    # Maximum number of jobs to run concurrently on this specific runner.
    # Defaults to 0, simply means don't limit.
    concurrent_specific: '0'
    docker_image: 'alpine'
    # Indicates whether this runner can pick jobs without tags.
    run_untagged: true
    machine_IdleCount: 1
    machine_IdleTime: 1800
    machine_MaxBuilds: 10
    machine_MachineDriver: 'amazonec2'
    machine_MachineName: 'git-runner-%s'
    machine_MachineOptions: ["amazonec2-access-key={{ lookup('env','AWS_IAM_ACCESS_KEY') }}", "amazonec2-secret-key={{ lookup('env','AWS_IAM_SECRET_KEY') }}", "amazonec2-zone={{ lookup('env','AWS_EC2_ZONE') }}", "amazonec2-region={{ lookup('env','AWS_EC2_REGION') }}", "amazonec2-vpc-id={{ lookup('env','AWS_VPC_ID') }}", "amazonec2-subnet-id={{ lookup('env','AWS_SUBNET_ID') }}", "amazonec2-use-private-address=true", "amazonec2-tags=gitlab-runner", "amazonec2-security-group={{ lookup('env','AWS_EC2_SECURITY_GROUP') }}", "amazonec2-instance-type={{ lookup('env','AWS_EC2_INSTANCE_TYPE') }}"]
    machine_autoscaling:
      - Periods: ["* * 7-18 * * mon-fri *"]
        Timezone: "UTC"
        IdleCount: 3
        IdleTime: 900
      - Periods: ["* * * * * sat,sun *"]
        Timezone: "UTC"
        IdleCount: 0
        IdleTime: 300
```

### NOTE
from https://docs.gitlab.com/runner/executors/docker_machine.html:

>The **first time** you’re using Docker Machine, it’s best to execute **manually** `docker-machine create...` with your chosen driver and **all options from the MachineOptions** section. This will set up the Docker Machine environment properly and will also be a good validation of the specified options. After this, you *can destroy the machine* with `docker-machine rm [machine_name]` and start the Runner.

Example:

```docker-machine create -d amazonec2 --amazonec2-zone=a --amazonec2-region=us-east-1 --amazonec2-vpc-id=vpc-11111111 --amazonec2-subnet-id=subnet-1111111 --amazonec2-use-private-address=true --amazonec2-tags=gitlab-runner --amazonec2-instance-type=t3.medium test

docker-machine rm test
```

Run As A Different User
-----------------------
To run the Gitlab Runner as a different user (rather than the default `gitlab-runner` user), there is a workaround requiring a little
extra Ansible to be run. See https://github.com/riemers/ansible-gitlab-runner/issues/277 for details.

Contributors
------------
Feel free to add your name to the readme if you make a PR. A full list of people from the PR's is [here](https://github.com/riemers/ansible-gitlab-runner/pulls?q=is%3Apr+is%3Aclosed)

- Gastrofix for adding Mac Support
- Matthias Schmieder for adding Windows Support
- dniwdeus & rosenstrauch for adding AWS autoscale option
- oscillate123 for fixing Windows config.toml idempotency
- [cchaudier](https://github.com/cchaudier) for fixing changing the version of a package which is on the apt hold list
