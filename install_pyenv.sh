#!/bin/bash

if [ ! -h $HOME/.pyenv ]; then
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
fi

if [ ! -h $HOME/.pyenv/plugins/pyenv-virtualenv ]; then
    git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
fi

export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_VERSION='2.7.12'
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv install 2.7.12
pyenv install 3.5.2

pyenv virtualenv 2.7.12 neovim2
pyenv virtualenv 3.5.2 neovim3

pyenv shell neovim2
pip install neovim pip pyflakes --upgrade
pyenv which python  # Note the path

pyenv shell neovim3
pip install neovim pip pyflakes --upgrade
pyenv which python  # Note the path