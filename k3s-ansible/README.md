# Ansible roles to install k3s cluster

This repository is used with ansible-pull from cloud-init instance

To develop and test
```
Configuration variables can be overrided with shell variables define in config.cfg
( source /home/$USER/config.cfg ; ansible-playbook -c local -i$(hostname -s), -b  local.yml -D -v )
```

To use corporate http_proxy, set env variable before running playbook or set in group_vars/all.yml
```
export https_proxy=http://corporate.proxy:3128
export https_proxy=http://corporate.proxy:3128
export no_proxy=.domain.internal
```
