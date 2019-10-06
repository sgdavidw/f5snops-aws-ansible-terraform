#!/bin/bash
export PATH=$PATH:~/marfil-f5-terraform/scripts

if [ -f *.emailid ]; then 
export emailid=$(basename `ls *.emailid` .emailid);
echo "emailid exists and is ${emailid}";
else echo "Zero or multiple emailids! Something went wrong."
fi
export AWS_ACCESS_KEY_ID=`cat aws_accesskeys_${emailid}.json | jq --raw-output .AccessKey.AccessKeyId`
export AWS_SECRET_ACCESS_KEY=`cat aws_accesskeys_${emailid}.json | jq --raw-output .AccessKey.SecretAccessKey`
region=`aws configure get region`
export AWS_DEFAULT_REGION=$region

export TF_VAR_aws_region=${AWS_DEFAULT_REGION}
export TF_VAR_terraform_aws_vpc=terraform-vpc-${emailid}
export TF_VAR_aws_keypair=MyKeyPair-${emailid}
export TF_VAR_emailid=${emailid}
export TF_VAR_emailidsan=`echo ${emailid} | sed 's/[\@._-]//g'`
sleep 5
export TF_VAR_aws_alias=https://`aws iam list-account-aliases | jq --raw-output .AccountAliases[]`.signin.aws.amazon.com/console
export TF_VAR_bigIqLicenseManager=$(get-bigiq)
export ANSIBLE_HOSTS=/etc/ansible/ec2.py
export EC2_INI_PATH=/etc/ansible/ec2.ini
echo "TF_VAR_bigIqLicenseManager value is ${TF_VAR_bigIqLicenseManager}."
