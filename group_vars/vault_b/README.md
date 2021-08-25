# What is this empty directory?

This is where Ansible will store sensitive information like the unseal key and
root-token in a file called `vault.yml`. You can use the information from that
file to login (or unseal) and Ansible will use the information as well to login
and/or unseal.
