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
  yum install -y epel-release
  yum install -y git xinetd
  yum install -y python-pip
  yum groupinstall -y 'Development Tools'
  yum install -y libffi libffi-devel openssl-devel python-devel
  pip install paramiko PyYAML Jinja2 httplib2 six

  # Install Ansible! We use pip as the EPEL package runs on Python 2.6...
  pip install ansible==1.9.4

  # Download our Ansible repository and run the given playbook. Pip installs
  # executables into a directory not in the root users $PATH.
  #/usr/local/bin/ansible-pull --accept-host-key --verbose \
  #  --url "$url" --directory /var/local/src/instance-bootstrap "$playbook"
  mkdir /ephemeral
  mkfs.xfs /dev/xvdb -f
  mount /dev/xvdb /ephemeral; 
 
  cp /tmp/*tgz /root/
  cd /root/
  tar xvzf /root/*tgz
  cd /root/infrastructure_aws
  # replace local ip of this node in hosts file
  private_local_ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
  sed -i "s/jenkins ansible_ssh_host=XX.XX.XX.XX/jenkins ansible_ssh_host=${private_local_ip}/" /root/infrastructure_aws/hosts/ec2-hj.hosts
  ansible-playbook -i /root/infrastructure_aws/hosts/ec2-hj.hosts -c local /root/infrastructure_aws/NDS-build-env.yaml
  

  # strip until ssh-rsa in /root/.ssh/authorized_keys
  sed -i "s/^.* ssh-rsa/ssh-rsa/" /root/.ssh/authorized_keys 

  # now clone hotjar etl ingestion git repo and compile
  cd /root/
  git clone https://github.com/sasubillis/hotjar_etl.git
  cd /root/hotjar_etl
  sbt assembly
}

#main \
#  'https://github.com/sasubillis/terraform-ansible.git' \
#  'ansible/local.yml'

main
