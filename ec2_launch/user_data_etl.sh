#!/bin/bash
#
# Install Ansible and use `ansible-pull` to run the playbook for this instance.

# Some sane options.
set -e # Exit on first error.
set -x # Print expanded commands to stdout.

function main {
  # Set our named arguments.
  #declare -r url=$1 playbook=$2

  # Ensure the instance is up-to-date.
  yum update -y

  # Install required packages.
  yum install -y epel-release xinetd

  # Download our Ansible repository and run the given playbook. Pip installs
  # executables into a directory not in the root users $PATH.
  #/usr/local/bin/ansible-pull --accept-host-key --verbose \
  #  --url "$url" --directory /var/local/src/instance-bootstrap "$playbook"
  mkdir /ephemeral
  mkfs.xfs /dev/xvdb -f
  mount /dev/xvdb /ephemeral; 

  # strip until ssh-rsa in /root/.ssh/authorized_keys
  sed -i "s/^.* ssh-rsa/ssh-rsa/" /root/.ssh/authorized_keys

 
}

#main \
#  'https://github.com/sasubillis/terraform-ansible.git' \
#  'ansible/local.yml'

main
