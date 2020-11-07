#!/bin/bash

USE_APT_GET=$(which apt-get >/dev/null 2>&1 && echo "true")
USE_PAMAC=$(which pamac >/dev/null 2>&1 && echo "true")

mkdir -p ~/.config/dunst
ln -s ~/dotfiles/dunst/dunstrc ~/.config/dunst/dunstrc

if [ -n "$USE_PAMAC" ]
then
    pamac install dunst
fi

if [ -n "$USE_APT_GET" ]
then
    sudo apt install dunst
    sudo systemctl restart dunst.service
fi
