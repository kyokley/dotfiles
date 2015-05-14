#!/bin/bash
# Be sure to run !!!!!!!!!!!!!!!!!!!!!!!!!!!
#    compinit
# in zsh after this script runs

ZSHRC=$HOME/.zshrc
BIN=$HOME/dotfiles/prezto/modules
DIR=$BIN/wd
MANLOC=/usr/share/man/man1
INSTALL_DIR=`pwd`

if [ -e ~/.bashrc ]; then
    mv ~/.bashrc ~/.bashrc_bak
fi
ln -s ~/dotfiles/bashrc ~/.bashrc

sudo aptitude install zsh terminator fonts-inconsolata

if [ ! -h ~/.zprezto ]; then
    ln -s ~/dotfiles/prezto ~/.zprezto
fi

ln -s ~/dotfiles/prezto/runcoms/zlogin ~/.zlogin
ln -s ~/dotfiles/prezto/runcoms/zlogout ~/.zlogout
ln -s ~/dotfiles/prezto/runcoms/zpreztorc ~/.zpreztorc
ln -s ~/dotfiles/prezto/runcoms/zprofile ~/.zprofile

if [ ! -h ~/.zshrc ]; then
    ln -s ~/dotfiles/prezto/runcoms/zshrc ~/.zshrc
    while true
    do
        echo "Would you like to install the man page for wd? (requires root access) (Y/n)"
        read -r answer
#
        case "$answer" in
            Y|y|YES|yes|Yes )
                echo "Installing man page to ${MANLOC}/wd.1"
                sudo mkdir -p ${MANLOC}
                sudo cp -f ${DIR}/wd.1 ${MANLOC}/wd.1
                sudo chmod 644 ${MANLOC}/wd.1
                break
                ;;
            N|n|NO|no|No )
                echo "If you change your mind, see README for instructions"
                break
                ;;
            * )
                echo "Please provide a valid answer (y or n)"
                ;;
        esac
    done

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
git clone https://github.com/facebook/PathPicker.git
cd PathPicker
ln -s "$(pwd)/fpp" /usr/local/bin/fpp
cd $INSTALL_DIR
