#!/bin/bash

PY3='3.8.2'

if [ ! -h $HOME/.pyenv ]; then
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
fi

if [ ! -h $HOME/.pyenv/plugins/pyenv-virtualenv ]; then
    git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
fi

if [ ! -h $HOME/.pyenv/plugins/pyenv-update ]; then
    git clone https://github.com/pyenv/pyenv-update.git $(pyenv root)/plugins/pyenv-update
fi

export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_VERSION="$PY3"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv install $PY3

pyenv virtualenv $PY3 neovim3

pyenv shell neovim3
pip install pip --upgrade
pip install python-language-server[all] neovim pip pyflakes flake8 bandit black --upgrade
pyenv which python  # Note the path

pyenv global $PY3
