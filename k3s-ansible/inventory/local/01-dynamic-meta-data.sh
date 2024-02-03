#!/usr/bin/env bash
#
# quick dynamic inventory script
#   assign host to ansible group define in meta-data tags "kube_groups"
#   kube_groups = "group_a,group_b"
#

hostname="$(hostname -s)"
KUBE_GROUPS="$(curl --retry 20 --retry-delay 5 -qs http://169.254.169.254/latest/meta-data/tags/kube_groups)"

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
     "_meta": { "hostvars": { "${hostname}": {} } }
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
