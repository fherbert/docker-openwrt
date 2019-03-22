FROM debian:stretch

# System update
RUN apt-get update && apt-get -y upgrade

RUN apt install -y build-essential libncurses5-dev gawk git libssl-dev gettext zlib1g-dev swig unzip time wget file python vim

RUN useradd -m itron && echo "itron:itron" | chpasswd && adduser itron sudo
USER itron
WORKDIR /home/itron
ADD configs /home/itron/itronconfig
RUN mkdir .ssh && ssh-keyscan server.herbert.org.nz > ~/.ssh/known_hosts && \
    cp /home/itron/itronconfig/id_ed25519_itronhab01_build ~/.ssh/id_ed25519 && \
    chmod 0600 ~/.ssh/id_ed25519 && \
    git clone git@server.herbert.org.nz:fherbert1/lede.git
WORKDIR /home/itron/lede
RUN git checkout itronhab_master && \
    cp feeds.conf.default feeds.conf && echo "src-git itron git@server.herbert.org.nz:itron/itron-feed.git;lede-latest" >> feeds.conf && \
    scripts/feeds update -a && \
    cp feeds/itron/pwm-ir-tx/Makefile package/kernel/linux/modules/rc.mk && \
    cp feeds/itron/pwm-ir-tx/999-lirc_bufsize.patch target/linux/generic/pending-4.14/ && \
    scripts/feeds install -a && \
    cp /home/itron/itronconfig/diffconfig .config && make defconfig
RUN make download && make toolchain/install -j4
CMD ["bash"]
