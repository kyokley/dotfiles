FROM manjarolinux/base AS manjaro

WORKDIR /root/dotfiles
RUN sed -i "s/\[options\]/[options]\nColor\nILoveCandy\n/" /etc/pacman.conf && \
        pacman -Syyu --noconfirm && pacman-db-upgrade && pacman -S --noconfirm pamac-cli wget
COPY . /root/dotfiles
RUN /bin/bash /root/dotfiles/install/install_pyenv.sh \
        && /bin/bash /root/dotfiles/install/install.sh

ENTRYPOINT ["/usr/bin/zsh"]

FROM ubuntu AS ubuntu
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Chicago
ENV TERM=linux
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo 'DPkg::options { "--force-confdef"; };' >> /etc/apt/apt.conf
WORKDIR /root/dotfiles
COPY ./tests/keyboard /etc/default/keyboard
RUN apt-get update && \
        apt-get install --no-install-recommends -y sudo git wget
COPY . /root/dotfiles
RUN /bin/bash /root/dotfiles/install/install_pyenv.sh \
        && /bin/bash /root/dotfiles/install/install.sh

ENTRYPOINT ["/usr/bin/zsh"]
