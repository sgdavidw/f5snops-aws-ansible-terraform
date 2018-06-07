#!/bin/bash

#Call from ./scripts/export.sh
#export ANSIBLE_HOSTS=/etc/ansible/ec2.py
#export EC2_INI_PATH=/etc/ansible/ec2.ini 

mkdir /etc/ansible/

wget -O /etc/ansible/ansible.cfg https://raw.githubusercontent.com/F5Networks/f5-ansible/devel/examples/ansible.cfg

wget -O /etc/ansible/ec2.py https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py
chmod +x /etc/ansible/ec2.py

wget -O /etc/ansible/ec2.ini https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini
sed -i '/elasticache = False/s/^#//g' /etc/ansible/ec2.ini
sed -i "s/regions = all/regions = auto/g" /etc/ansible/ec2.ini

ln -s /etc/ansible/ec2.py ./scripts/ec2.py
