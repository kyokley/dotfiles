#!/bin/bash

pamac install docker docker-compose
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
