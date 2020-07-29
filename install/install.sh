#!/bin/bash
# Be sure to run !!!!!!!!!!!!!!!!!!!!!!!!!!!
#    compinit
# in zsh after this script runs

git submodule update --init --recursive

ZSHRC=$HOME/.zshrc
BIN=$HOME/dotfiles/prezto/modules
DIR=$BIN/wd
MANLOC=/usr/share/man/man1

USE_APT_GET=$(which apt-get >/dev/null 2>&1 && echo "true")
USE_PAMAC=$(which apt-get >/dev/null 2>&1 && echo "true")

ln -s ~/dotfiles/psqlrc ~/.psqlrc

if [ -e ~/.bashrc ]; then
    mv ~/.bashrc ~/.bashrc_bak
fi
ln -s ~/dotfiles/bashrc ~/.bashrc

if [ -n $USE_PAMAC ]
then
    pamac install the_silver_searcher ttf-inconsolata noto-fonts-emoji bluez-utils ttf-hack kitty
    pamac build nerd-fonts-inconsolata
    fc-cache -f -v

    mkdir -p ~/.config/kitty
    ln -s ~/dotfiles/kitty.conf ~/.config/kitty/
fi

if [ -n $USE_APT_GET ]
then
    sudo aptitude purge gnome-screensaver -y
    sudo aptitude install -y zsh terminator fonts-inconsolata silversearcher-ag xscreensaver xscreensaver-screensaver-bsod direnv fonts-hack-ttf
fi

if [ ! -h ~/.zprezto ]; then
    ln -s ~/dotfiles/prezto ~/.zprezto
fi

ln -s ~/dotfiles/prezto/runcoms/zlogin ~/.zlogin
ln -s ~/dotfiles/prezto/runcoms/zlogout ~/.zlogout
ln -s ~/dotfiles/prezto/runcoms/zpreztorc ~/.zpreztorc
ln -s ~/dotfiles/prezto/runcoms/zprofile ~/.zprofile

if [ ! -h ~/.zshrc ]; then
    ln -s ~/dotfiles/prezto/runcoms/zshrc ~/.zshrc
    echo "Installing man page to ${MANLOC}/wd.1"
    sudo mkdir -p ${MANLOC}
    sudo cp -f ${DIR}/wd.1 ${MANLOC}/wd.1
    sudo chmod 644 ${MANLOC}/wd.1
    rm -f ~/.zcompdump
fi

ln -s ~/dotfiles/prezto/runcoms/zshenv ~/.zshenv

if [ ! -h $HOME/.ipython ]; then
    ln -s ~/dotfiles/ipython ~/.ipython
fi

if [ -e /usr/bin/zsh ]; then
    chsh -s /usr/bin/zsh
fi

if [ ! -e "$HOME/.config/terminator" ]
then
    mkdir "$HOME/.config/terminator"
fi

mv "$HOME/.config/terminator/config" "$HOME/.config/terminator/config_bak"
ln -s "$HOME/dotfiles/termConfig" "$HOME/.config/terminator/config"

mv "$HOME/.gitconfig"  "$HOME/.gitconfig_bak"
ln -s "$HOME/dotfiles/gitconfig" "$HOME/.gitconfig"

mv "$HOME/.noserc"  "$HOME/.noserc_bak"
ln -s "$HOME/dotfiles/noserc" "$HOME/.noserc"

ln -s "$HOME/dotfiles/npmrc" "$HOME/.npmrc"

ln -s "$HOME/dotfiles/xscreensaver" "$HOME/.xscreensaver"

ln -s "$HOME/dotfiles/pdbrc.py" "$HOME/.pdbrc.py"

git clone https://github.com/kyokley/PathPicker.git $HOME/.local/share/PathPicker
ln -s "$HOME/.local/share/PathPicker/fpp" $HOME/.local/bin/fpp

# Grab sec opts for chrome
wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ~/chrome_sec.json
