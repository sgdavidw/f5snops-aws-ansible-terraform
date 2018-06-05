#!/bin/bash

#apk update for ab
apk update

#install ab
apk add apache2-utils

#install gettext
apk add gettext

#install jq
apk add jq

#install openssl
apk add openssl

#install wget
apk add wget

#Add libraries to compile ansible
apk add --update gcc python2-dev linux-headers libc-dev libffi libffi-dev openssl openssl-dev

#upgrade pip
pip install --upgrade pip

#install boto3
pip install boto3

#install boto - ec2.py requirement
pip install boto

#install ansible
pip install ansible bigsuds f5-sdk netaddr deepdiff

#install terraform
curl -O https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip
unzip ./terraform_0.9.11_linux_amd64.zip
mv ./terraform /usr/local/bin/
echo "terraform --version"
echo `terraform --version`
