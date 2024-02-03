#!/bin/bash
set -e -o pipefail
echo "# INFO start ansible.sh $(date)"

cloud_user=outscale
libdir=/home/$cloud_user

# Load config if exists
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg

# retry in case of network delay
echo 'Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries

# install dependencies
PACKAGES="sudo curl jq apt-transport-https ca-certificates curl software-properties-common gnupg make git unzip python3-pip"
DEFAULT_TIMEOUT=${DEFAULT_TIMEOUT:-1200}
test_result=1
timeout=$DEFAULT_TIMEOUT
set +e
until [ "$timeout" -le 0 -o "$test_result" -eq 0 ] ; do
  ( apt-get -q update && apt-get install -qy --no-install-recommends $PACKAGES )
  test_result=$?
  if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
  fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: apt-get failed: network not ready $test_result"
        exit $test_result
fi

set -e
# install ansible from pip
export ansible_version="${ansible_version:-ansible}"
python3 -m pip --timeout 120  install --break-system-packages ansible
ansible --version

# run ansible-pull if url defined
if [ -n "${ansible_pull_url}" ]; then
    echo "# ansible-pull $ansible_pull_url"
    dest_dir=${libdir}/$(basename $ansible_pull_url)
    ansible-pull -c local --diff --clean -U $ansible_pull_url -d $dest_dir ${ansible_pull_args}
fi
echo "# INFO end ansible.sh $(date)"
