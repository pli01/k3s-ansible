# Ansible roles to install k3s cluster

This repository is used to install k3s cluster with ansible-pull from cloud-init instance
It support to deployment mode
- ansible-playbook in local connection (used with cloud-init at initiation nodes) 
- ansible-playbook to all cluster nodes (push mode and remote ssh connection)

## install cluster nodes

2 mode supported:

Either in pull mode and local connection from each nodes (self auto config)
```
- Configuration variables  and roles can be overrided with shell variables define in config.cfg
- inventory is dynamically build from meta-data tags kube_groups (at provisionning time)
- each node execute
( source /home/$USER/config.cfg ; ansible-playbook -c local -i inventory/local -b  local.yml -D -v )
```

Or from central deployer host,  in push mode and ssh connection

```
- Configuration variables can be overrided with shell variables define in config.cfg
- Build your inventory file , from dynamic or static file
- exemple: copy inventory/remove/01-hosts to inventory/remote/01-custom  and replace with your inventory
( source /home/$USER/config.cfg ; ansible-playbook -i inventory/remote -b cluster.yml -D -v )
```

To use corporate `http_proxy`, set env variable before running playbook or set in group_vars/all.yml
```
export https_proxy=http://corporate.proxy:3128
export https_proxy=http://corporate.proxy:3128
export no_proxy=.domain.internal
```

## Uninstall all cluster nodes

```
# pull mode
ansible-playbook -c local -i inventory/local -b uninstall.yml -v
# push mode
ansible-playbook -i inventory/remote -b uninstall.yml -v
```

# Versions

ansible: 2.16.3

group_vars/all/docker.yml
```
docker_compose_version_default: "v2.23.3"
docker_version_default: "docker-ce=5:24.0.9-1~debian.12~bookworm"
```

group_vars/all/k3s.yml
```
k3s_version_default: v1.28.5+k3s1
```

group_vars/all/ingress-nginx.yml
```
ingress_nginx_chart_version: v4.9.0
```

`TODO`
CNI
CSI

# K3S Cluster configurations

use `K3S_*` variables to configure

see:
- https://docs.k3s.io/cli/server
- https://docs.k3s.io/cli/agent

Some variables defined per node:

K3S_CLUSTER_INIT: define node as first ctrl plane node . Initialize a new cluster using embedded Etcd
K3S_SERVER: define node as server. Set on on all other ctrl plane  node (not one init node)
K3S_AGENT: define node as agent
K3S_URL: define url of cluster ctrl plane node (first ctrl plane node or vip )
K3S_TOKEN: define the token used to enrolle all ctrl plane and agent to first ctrl node
NODE_TAINTS: define taint of ctrl plane node. If CriticalAddonsOnly is defined, all ctrl plane will be dedicated api, no workload on it

Some configuration:
- inventory,group name for a node can be defined with cloud-init meta-data tags, using kube_groups tags (http://169.254.169.254/latest/meta-data/tags/kube_groups)
  - kube_groups=master_init : define the node in master_init group (first ctrl plane node)
  - kube_groups=master_add : define the node in master_add group (other ctrl plane node)
  - kube_groups="worker_app,agent" : define the node in 2 groups (worker_app and agent) group (worker agent node)
- node_labels for a node can be defined with cloud-init meta-data tags (http://169.254.169.254/latest/meta-data/tags/k3s.label.XXX)
  - k3s.label.web=true: will affect a label (web=true) to the node
  - k3s.label.ingress=true: will affect a label (web=true) to the node 
