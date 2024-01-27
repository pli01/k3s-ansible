# k3s-terraform-ansible

Deploy K3s clusters with terraform and ansible

- k3-tf-outscale: terraform for Outscale cloud (based on https://github.com/pli01/terraform-outscale-vpc module)
- cloud-init: necessary file initialize instances and start ansible-pull playbook
- k3-ansible: ansible playbook and roles to deploy k3s cluster
