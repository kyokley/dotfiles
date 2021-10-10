export DOCKER_BUILDKIT=1

manjaro-build:
	docker build -t kyokley/dotfiles --target=manjaro -f tests/Dockerfile .

ubuntu-build:
	docker build -t kyokley/dotfiles --target=ubuntu -f tests/Dockerfile .

manjaro-shell: manjaro-build
	docker run --rm -it kyokley/dotfiles

ubuntu-shell: ubuntu-build
	docker run --rm -it kyokley/dotfiles

test-manjaro-install: manjaro-build
	docker run --rm -t kyokley/dotfiles -c exit

test-ubuntu-install: ubuntu-build
	docker run --rm -t kyokley/dotfiles -c exit
