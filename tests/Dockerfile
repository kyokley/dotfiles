FROM manjarolinux/base AS manjaro

WORKDIR /root/dotfiles
RUN sed -i "s/\[options\]/[options]\nColor\nILoveCandy\n/" /etc/pacman.conf && \
        pacman -Syyu && yes | pacman -Syu pamac-cli wget

CMD ["/bin/bash"]

FROM ubuntu AS ubuntu
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo 'DPkg::options { "--force-confdef"; };' >> /etc/apt/apt.conf
WORKDIR /root/dotfiles
RUN apt-get update && \
        apt-get install --no-install-recommends -y sudo git wget
CMD ["/bin/bash"]
