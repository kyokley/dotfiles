#!/bin/bash

USE_PAMAC=$(which apt-get >/dev/null 2>&1 && echo "true")
USE_APT_GET=$(which apt-get >/dev/null 2>&1 && echo "true")

if [ -n $USE_PAMAC ]
then
    pamac install docker docker-compose
fi

if [ -n $USE_APT_GET ]
then
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    sudo apt-get update
    sudo apt-get install docker-ce
fi

sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker

sudo docker run hello-world
if [ $? != 0 ];
then
    echo "Failed to run docker container. Try restarting then try again."
    exit 1
else
    echo "Success! All done."
fi
