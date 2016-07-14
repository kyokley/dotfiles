#!/bin/bash
# Be sure to run !!!!!!!!!!!!!!!!!!!!!!!!!!!
#    compinit
# in zsh after this script runs

git submodule update --init --recursive

ZSHRC=$HOME/.zshrc
BIN=$HOME/dotfiles/prezto/modules
DIR=$BIN/wd
MANLOC=/usr/share/man/man1
INSTALL_DIR=`pwd`

ln -s ~/dotfiles/psqlrc ~/.psqlrc

if [ -e ~/.bashrc ]; then
    mv ~/.bashrc ~/.bashrc_bak
fi
ln -s ~/dotfiles/bashrc ~/.bashrc

sudo aptitude install -y zsh terminator fonts-inconsolata silversearcher-ag

if [ ! -h ~/.zprezto ]; then
    ln -s ~/dotfiles/prezto ~/.zprezto
fi

ln -s ~/dotfiles/prezto/runcoms/zlogin ~/.zlogin
ln -s ~/dotfiles/prezto/runcoms/zlogout ~/.zlogout
ln -s ~/dotfiles/prezto/runcoms/zpreztorc ~/.zpreztorc
ln -s ~/dotfiles/prezto/runcoms/zprofile ~/.zprofile

if [ ! -h ~/.zshrc ]; then
    ln -s ~/dotfiles/prezto/runcoms/zshrc ~/.zshrc
    rm -f ~/.zcompdump
fi

ln -s ~/dotfiles/prezto/runcoms/zshenv ~/.zshenv

if [ -e ~/.ipython ]; then
    mv ~/.ipython ~/.ipython_bak
fi

ln -s ~/dotfiles/ipython ~/.ipython

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

cd $INSTALL_DIR
cd PathPicker
sudo ln -s "$(pwd)/fpp" /usr/local/bin/fpp
cd $INSTALL_DIR
