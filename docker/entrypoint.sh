#!/bin/bash
ARGS="$@"
DIR="/cvp"
export CLOUDSDK_CONFIG=$DIR/.gcloud

mkdir -p $HOME/.config
test -d $CLOUDSDK_CONFIG && cp -pr $CLOUDSDK_CONFIG $HOME/.config/gcloud

if [ ! -f $DIR/.ssh/id_rsa ]; then 
  mkdir -p $DIR/.ssh
  ssh-keygen -t rsa -N '' -f $DIR/.ssh/id_rsa
  echo "SSH keys to access instances have been generated and are available in the .ssh directory."
fi
cp -pr $DIR/.ssh $HOME

gcloudInit() {
  echo "During setup you'll be asked to log in to your google account twice."
  gcloud config configurations create cvp-profile
  gcloud config configurations activate cvp-profile
  gcloud init --no-launch-browser --skip-diagnostics
  clear
  gcloud auth application-default login --no-launch-browser
  cp -pr $CLOUDSDK_CONFIG $HOME/.config/gcloud
  echo "Your gcloud configuration has been generated and is available in the .gcloud directory."
}

if [ ! -f $DIR/main.tf ]; then
  echo Terraform files not found
  exit 1
fi

test -d $CLOUDSDK_CONFIG || gcloudInit
test -d $DIR/.terraform  || terraform init

terraform $ARGS