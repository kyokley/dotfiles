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

pamac install the_silver_searcher ttf-inconsolata noto-fonts-emoji bluez-utils ttf-hack
pamac build nerd-fonts-inconsolata
fc-cache -f -v

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

cd $INSTALL_DIR
cd PathPicker
sudo ln -s "$(pwd)/fpp" /usr/local/bin/fpp
cd $INSTALL_DIR

# Grab sec opts for chrome
wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ~/chrome_sec.json