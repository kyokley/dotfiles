#!/bin/bash

docker run -it --rm --cpuset-cpus 0 --memory 512mb -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v $HOME/Downloads:/root/Downloads --privileged kyokley/vpn
