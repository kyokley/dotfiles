#!/bin/bash

PY27='2.7.13'
PY3='3.6.2'

if [ ! -h $HOME/.pyenv ]; then
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
fi

if [ ! -h $HOME/.pyenv/plugins/pyenv-virtualenv ]; then
    git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
fi

sudo aptitude update
sudo aptitude install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev

export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_VERSION="$PY27"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv install $PY27
pyenv install $PY3

pyenv virtualenv $PY27 neovim2
pyenv virtualenv $PY3 neovim3

pyenv shell neovim2
<<<<<<< HEAD
pip install python-language-server[all] neovim pip pyflakes flake8 bandit --upgrade
pyenv which python  # Note the path

pyenv shell neovim3
pip install python-language-server[all] neovim pip pyflakes flake8 bandit --upgrade
=======
pip install pip --upgrade
pip install python-language-server[all] neovim pip pyflakes bandit --upgrade
pyenv which python  # Note the path

pyenv shell neovim3
pip install pip --upgrade
pip install python-language-server[all] neovim pip pyflakes bandit --upgrade
>>>>>>> 6d255dd9e5d39e0b2e25b51e750b9ac81f1b567c
pyenv which python  # Note the path
