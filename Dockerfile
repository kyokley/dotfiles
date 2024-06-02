FROM nixos/nix

RUN nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && \
        nix-channel --update

RUN useradd -ms /bin/bash newuser

USER newuser
WORKDIR /home/newuser
