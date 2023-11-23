#!/bin/bash

USE_PAMAC=$(which pamac >/dev/null 2>&1 && echo "true")
USE_APT_GET=$(which apt-get >/dev/null 2>&1 && echo "true")

if [ -n $USE_PAMAC ]
then
    pamac install docker docker-compose
fi

if [ -n $USE_APT_GET ]
then
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

sudo docker run hello-world
if [ $? != 0 ];
then
    echo "Failed to run docker container. Try restarting then try again."
    exit 1
else
    echo "Success! All done."
fi
