GitLab Runner
=============

This role will install the official GitLab Runner

Requirements
------------

This role requires Ansible 2.0 or higher.


Role Variables
--------------

```gitlab_runner_concurrent```
The maximum number of jobs to run concurrently.
Defaults to the number of processor cores.

```gitlab_runner_coordinator_url```
The GitLab coordinator URL.
Defaults to ```https://gitlab.com/ci```.

```gitlab_runner_registration_token```
The GitLab registration token.

```gitlab_runner_description```
The description of the runner.
Defaults to the hostname.

```gitlab_runner_executor```
The executor used by the runner.
Defaults to ```shell```.

```gitlab_runner_tags```
The tags assigned to the runner,
Defaults to an empty list.

Dependencies
------------

None

Example Playbook
----------------


License
-------

MIT
