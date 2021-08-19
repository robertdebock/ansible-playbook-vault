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
