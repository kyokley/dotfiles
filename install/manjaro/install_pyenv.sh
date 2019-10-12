#!/bin/bash

PY27='2.7.15'
PY3='3.6.7'

if [ ! -h $HOME/.pyenv ]; then
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
fi

if [ ! -h $HOME/.pyenv/plugins/pyenv-virtualenv ]; then
    git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
fi

export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_VERSION="$PY27"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv install $PY27
pyenv install $PY3

pyenv virtualenv $PY27 neovim2
pyenv virtualenv $PY3 neovim3

pyenv shell neovim2
pip install pip --upgrade
pip install python-language-server[all] neovim pip pyflakes flake8 bandit --upgrade
pyenv which python  # Note the path

pyenv shell neovim3
pip install pip --upgrade
pip install python-language-server[all] neovim pip pyflakes flake8 bandit black --upgrade
pyenv which python  # Note the path

pyenv global $PY3 $PY27
