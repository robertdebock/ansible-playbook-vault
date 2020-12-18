# Vault Upgrade playbook

Try upgrades of Vault over DR and HA clusters.

## Overview

This setup consists of:
- 1 Disaster Recovery (DR) cluster
- 2 Highly Available (HA) clusters
- 2 HashiCorp Vault leaders, 1 in each HA cluster.
- 4 HashiCorp Vault followers, 2 in echa HA cluster.

```text
+------------------- DR cluster --------------------+
| +--- HA cluster "A" ---+ +--- HA cluster "B" ---+ |
| | +--- vault-a-1 ---+  | | +--- vault-b-1 ---+  | |
| | | leader          |  | | | leader          |  | |
| | +-----------------+  | | +-----------------+  | |
| | +--- vault-a-2 ---+  | | +--- vault-b-2 ---+  | |
| | | follower        |  | | | follower        |  | |
| | +-----------------+  | | +-----------------+  | |
| | +--- vault-a-3 ---+  | | +--- vault-b-3 ---+  | |
| | | follower        |  | | | follower        |  | |
| | +-----------------+  | | +-----------------+  | |
| +----------------------+ +----------------------+ |
+---------------------------------------------------+
```

## Prepare

Start the virtual machines.

```shell
vagrant up
```

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
# First setup one HA cluster with the name "a".
./1_install_vault.yml --limit a
# Now setup the other HA cluster, call it "b".
./1_install_vault.yml --limit b
# This playbook saves the unseal_keys in `group_vars/(a|b)/vault.yml`.
# Make a backup, save the results to /root/.
./2_backup_vault.yml
# Upgrade the vault clusters.
./3_upgrade_vault.yml
# Setup DR cluster. Here is where cluster "a" and "b" are related.
./4_setup_dr.yml
# Generate a failover token, required to do a DR failover.
./5_generate_failover_token.yml
```

HashiCorp Vault enterprise seals itself after 30 minutes of use without entering a license. To develop procedures, restart and unseal Vault 30 minutes after starting up.

```shell
./9_restart_and_unseal.yml
```

## Cleanup

Throw away the machines.

```shell
vagrant destroy -f
```
