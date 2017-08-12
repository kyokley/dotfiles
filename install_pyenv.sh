#!/bin/bash

if [ ! -h $HOME/.pyenv ]; then
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
fi

if [ ! -h $HOME/.pyenv/plugins/pyenv-virtualenv ]; then
    git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
fi

pyenv install 2.7.12
pyenv install 3.5.2

pyenv virtualenv 2.7.12 neovim2
pyenv virtualenv 3.5.2 neovim3

pyenv activate neovim2
pip install neovim pip pyflakes --upgrade
pyenv which python  # Note the path

pyenv activate neovim3
pip install neovim pip pyflakes --upgrade
pyenv which python  # Note the path
