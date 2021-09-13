manjaro-build:
	docker build -t kyokley/dotfiles --target=manjaro tests

ubuntu-build:
	docker build -t kyokley/dotfiles --target=ubuntu tests

manjaro-shell: manjaro-build
	docker run --rm -it -v $$(pwd):/root/dotfiles kyokley/dotfiles

ubuntu-shell: ubuntu-build
	docker run --rm -it -v $$(pwd):/root/dotfiles kyokley/dotfiles

test-manjaro-install: manjaro-build
	docker run --rm -it -v $$(pwd):/root/dotfiles kyokley/dotfiles /usr/bin/bash -c '/root/dotfiles/install/install.sh && zsh -c exit'

test-ubuntu-install: ubuntu-build
	docker run --rm -it -v $$(pwd):/root/dotfiles kyokley/dotfiles /usr/bin/bash -c '/root/dotfiles/install/install.sh && zsh -c exit'
