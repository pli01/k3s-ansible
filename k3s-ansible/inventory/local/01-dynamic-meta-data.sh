#!/usr/bin/env bash
#
# quick dynamic inventory script
#   assign host to ansible group defined in meta-data tags "kube_groups"
#     kube_groups = "group_a,group_b"
#   assign node_label_list defined in meta-data tags "k3s.label"
#

hostname="$(hostname -s)"
KUBE_GROUPS="$(curl --retry 20 --retry-delay 5 -qs http://169.254.169.254/latest/meta-data/tags/kube_groups)"

meta_data_url=http://169.254.169.254/latest/meta-data/tags
meta_data_labels_key="$(curl -s $meta_data_url |grep k3s.label )"
meta_data_labels="$(for label in $meta_data_labels_key ; do curl -s $meta_data_url/$label |xargs -i echo \"${label#k3s.label.}={}\" ; done)"
NODE_LABELS="$(echo $meta_data_labels|sed -e 's/^/\[/;s/ /,/g;s/$/\]/')"

if [ "$1" == "--list" ]; then
cat<<EOF
{
EOF
echo "$KUBE_GROUPS" |tr ',' '\n' |while read group ; do
  cat <<EOF
     "${group}": { "hosts": [ "${hostname}" ] },
EOF
done
  cat <<EOF
     "_meta": { "hostvars": { "${hostname}": { "node_label_list": ${NODE_LABELS} } } }
}
EOF
elif [ "$1" == "--host" ]; then
     # this should not normally be called by Ansible as we return _meta above
     if [ "$2" == "${hostname}" ]; then
        cat <<EOF
{"_meta": {"hostvars": {"${hostname}": {"host_specific-test_var": "test-value"}}}}
EOF
     else
        echo '{"_meta": {"hostvars": {}}}'
     fi
   else
     echo "Invalid option: use --list or --host <hostname>"
     exit 1
fi
