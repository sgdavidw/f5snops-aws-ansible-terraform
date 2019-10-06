#!/bin/bash

#install aws-cli

pip install --upgrade --user awscli
export PATH=~/.local/bin:$PATH
export AWS_CONFIG_FILE=~/.aws/config
abort=0

if [ ! -d ~/.aws/ ]; then
  mkdir ~/.aws/
fi

if [ ! -f ~/.aws/credentials ]; then
# download aws keys from shortUrl
  if [ $F5_ENV == "development" ]
    then
    cd ~/.aws/ && { wget -O config https://shuo18cqe6.execute-api.us-east-1.amazonaws.com/p/${shortUrl} ; cd -; }
    else
    cd ~/.aws/ && { wget -O config https://pyndc37yn0.execute-api.us-east-1.amazonaws.com/p/${shortUrl} ; cd -; }
  fi

  grep secret ~/.aws/* &> /dev/null
  if [ $? != 0 ]
    then
    echo "Invalid shortUrl: $shortUrl.  Aborting".
    abort=1
  fi

else echo "AWS credentials previously configured.
"
fi

aws iam get-user --user-name $emailid &> /dev/null
if [ $? == 0 ]
  then
  echo "Existing user $emailid.  Aborting".
  abort=1
fi

echo "aws --version"
echo `aws --version`

#mark lab-info python script executable
chmod +x ./scripts/*

# if [ -z "$decryptPassword" ]; then
#    echo "Enter decryption password:
#    "
#    read decryptPassword
# fi

# openssl aes-256-cbc -d -a -in ~/.aws/config.enc -out ~/.aws/config -pass pass:$decryptPassword

cp ./scripts/.profile ~/.profile
if [ $abort == 0 ]
  then
  source ./scripts/addUser.sh
  else
  echo "Install aborted"
fi
# encrypt
# openssl aes-256-cbc -a -salt -in config -out config.enc
# echo $TF_VAR_bigIqLicenseManager bigiq >> /etc/hosts

