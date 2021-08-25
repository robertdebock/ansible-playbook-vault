# The amount of instances to spin up per Vault HA cluster.
# There are 2 clusters. Use an odd number, 1, 3, 5, etc.
# Using 1 does not allow losing any node.
# Using 3 allows losing 1 node.
# Using 5 allows losing 2 nodes.
amount = 1

# The size refers to the droplet size of each node. This value is mapped to
# DigitalOcean droples size names in `locals.tf`. Either "small" or "large".
size = "small"

# You can set the amount of loadbalancers. Loadbalancers are places in front of
# every cluster and in front of the two loadbalancers. This number, multiplied
# by 3 determines the number of instances.
loadbalancers = 1

# Consider these values and applications.

# |amount|size| loadbalancers|application     |
# |------|-----|-------------|----------------|
# |1     |small|1            |development     |
# |3     |small|2            |production small|
# |5     |large|2            |production      |
