# Vault Upgrade playbook

Try upgrades of Vault over DR and HA clusters.

## Overview

This setup consists of:

- 2 "global" loadbalancers
- 2*2 "local" loadbalancers
- 2 Highly Available (HA) clusters
- 1 Disaster Recovery (DR) cluster
- 2*1 HashiCorp Vault leaders, 1 in each HA cluster.
- 2*4 HashiCorp Vault followers, 4 in each HA cluster.

The loadbalancers are setup to:

1. Allow a loadbalancer outage.
2. Allow a datacenter outage.

```text
  +--- loadbalancer-0 ---+     +--- loadbalancer-1 ---+
  |                      +-+ +-+                      |
  +----------------------+ | | +----------------------+
+--- loadbalancer-a-0 ---+ | | +--- loadbalancer-b-0 ---+
|                        +-+ +-+                        |
+------------------------+ | | +------------------------+
+--- loadbalancer-a-1 ---+ | | +--- loadbalancer-b-1 ---+
|                        +-+ +-+                        |
+------------------------+     +------------------------+
```

The Vault cluster is setup like displayed below.

```text
+------------------- DR cluster --------------------+
| +--- HA cluster "A" ---+ +--- HA cluster "B" ---+ |
| | +--- vault-a-0 ---+  | | +--- vault-b-0 ---+  | |
| | | leader          |  | | | leader          |  | |
| | +-----------------+  | | +-----------------+  | |
| | +--- vault-a-1 ---+  | | +--- vault-b-1 ---+  | |
| | | follower        |  | | | follower        |  | |
| | +-----------------+  | | +-----------------+  | |
| | +--- vault-a-2 ---+  | | +--- vault-b-3 ---+  | |
| | | follower        |  | | | follower        |  | |
| | +-----------------+  | | +-----------------+  | |
| | +--- vault-a-3 ---+  | | +--- vault-b-3 ---+  | |
| | | follower        |  | | | follower        |  | |
| | +-----------------+  | | +-----------------+  | |
| | +--- vault-a-4 ---+  | | +--- vault-b-4 ---+  | |
| | | follower        |  | | | follower        |  | |
| | +-----------------+  | | +-----------------+  | |
| +----------------------+ +----------------------+ |
+---------------------------------------------------+
```

## Prepare

Download or update the Ansible roles.

```shell
ansible-galaxy install -r roles/requirements.yml -f
```

The state of the used roles:

|Role name|GitHub Action|GitLab CI|Version|
|---------|-------------|---------|-------|
|[bootstrap](https://galaxy.ansible.com/robertdebock/bootstrap)|[![github](https://github.com/robertdebock/ansible-role-bootstrap/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-bootstrap/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-bootstrap/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-bootstrap)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-bootstrap/latest.svg)](https://github.com/robertdebock/ansible-role-bootstrap/releases)|
|[common](https://galaxy.ansible.com/robertdebock/common)|[![github](https://github.com/robertdebock/ansible-role-common/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-common/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-common/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-common)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-common/latest.svg)](https://github.com/robertdebock/ansible-role-common/releases)|
|[core_dependencies](https://galaxy.ansible.com/robertdebock/core_dependencies)|[![github](https://github.com/robertdebock/ansible-role-core_dependencies/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-core_dependencies/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-core_dependencies/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-core_dependencies)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-core_dependencies/latest.svg)](https://github.com/robertdebock/ansible-role-core_dependencies/releases)|
|[digitalocean-agent](https://galaxy.ansible.com/robertdebock/digitalocean-agent)|[![github](https://github.com/robertdebock/ansible-role-digitalocean-agent/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-digitalocean-agent/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-digitalocean-agent/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-digitalocean-agent)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-digitalocean-agent/latest.svg)](https://github.com/robertdebock/ansible-role-digitalocean-agent/releases)|
|[environment](https://galaxy.ansible.com/robertdebock/environment)|[![github](https://github.com/robertdebock/ansible-role-environment/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-environment/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-environment/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-environment)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-environment/latest.svg)](https://github.com/robertdebock/ansible-role-environment/releases)|
|[haproxy](https://galaxy.ansible.com/robertdebock/haproxy)|[![github](https://github.com/robertdebock/ansible-role-haproxy/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-haproxy/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-haproxy/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-haproxy)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-haproxy/latest.svg)](https://github.com/robertdebock/ansible-role-haproxy/releases)|
|[hashicorp](https://galaxy.ansible.com/robertdebock/hashicorp)|[![github](https://github.com/robertdebock/ansible-role-hashicorp/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-hashicorp/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-hashicorp/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-hashicorp)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-hashicorp/latest.svg)](https://github.com/robertdebock/ansible-role-hashicorp/releases)|
|[keepalived](https://galaxy.ansible.com/robertdebock/keepalived)|[![github](https://github.com/robertdebock/ansible-role-keepalived/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-keepalived/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-keepalived/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-keepalived)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-keepalived/latest.svg)](https://github.com/robertdebock/ansible-role-keepalived/releases)|
|[logwatch](https://galaxy.ansible.com/robertdebock/logwatch)|[![github](https://github.com/robertdebock/ansible-role-logwatch/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-logwatch/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-logwatch/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-logwatch)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-logwatch/latest.svg)](https://github.com/robertdebock/ansible-role-logwatch/releases)|
|[service](https://galaxy.ansible.com/robertdebock/service)|[![github](https://github.com/robertdebock/ansible-role-service/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-service/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-service/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-service)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-service/latest.svg)](https://github.com/robertdebock/ansible-role-service/releases)|
|[users](https://galaxy.ansible.com/robertdebock/users)|[![github](https://github.com/robertdebock/ansible-role-users/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-users/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-users/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-users)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-users/latest.svg)](https://github.com/robertdebock/ansible-role-users/releases)|
|[vault](https://galaxy.ansible.com/robertdebock/vault)|[![github](https://github.com/robertdebock/ansible-role-vault/workflows/Ansible%20Molecule/badge.svg)](https://github.com/robertdebock/ansible-role-vault/actions)|[![gitlab](https://gitlab.com/robertdebock/ansible-role-vault/badges/master/pipeline.svg)](https://gitlab.com/robertdebock/ansible-role-vault)|[![version](https://img.shields.io/github/commits-since/robertdebock/ansible-role-vault/latest.svg)](https://github.com/robertdebock/ansible-role-vault/releases)|


## Test

Run the playbook against the virtual machines.

```shell
# Setup the machines with Vault 1.4.2.
# 1.4.2 is an old version, so you can try upgrades.
#
# First setup two HA clusters
./1_install_vault.yml
# This playbook saves the unseal_keys in `group_vars/vault_(a|b)/vault.yml`.
# Make a backup, save the results to /root/.
./2_backup_vault.yml
# Upgrade the vault clusters.
./3_upgrade_vault.yml
# Setup DR cluster. Here is where cluster "a" and "b" are related.
./4_setup_dr.yml
# Generate a failover token, required to do a DR failover.
./5_generate_failover_token.yml
```

HashiCorp Vault enterprise seals itself after 30 minutes of use without
entering a license. To develop procedures, restart and unseal Vault 30
minutes after starting up.

```shell
./9_restart_and_unseal.yml
```

## Cleanup

Throw away the machines.

```shell
cd terraform
terraform destroy
```
