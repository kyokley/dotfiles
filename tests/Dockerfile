FROM manjarolinux/base AS manjaro

WORKDIR /root/dotfiles
RUN sed -i "s/\[options\]/[options]\nColor\nILoveCandy\n/" /etc/pacman.conf && \
        pacman -Syyu && yes | pacman -Syu pamac-cli wget

CMD ["/bin/bash"]

FROM ubuntu AS ubuntu
WORKDIR /root/dotfiles
CMD ["/bin/bash"]
