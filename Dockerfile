FROM deb_build_base:latest

ADD configs /home/itron/itronconfig
RUN git clone --branch itronhab_master git@server.herbert.org.nz:fherbert1/lede.git
WORKDIR /home/itron/lede
RUN cp feeds.conf.default feeds.conf && \
    scripts/feeds update -a && \
    scripts/feeds install -a && \
    cp /home/itron/itronconfig/diffconfig .config && make defconfig && \
    make download && make toolchain/install -j4
RUN echo "src-git itron git@server.herbert.org.nz:itron/itron-feed.git" >> feeds.conf && \
    scripts/feeds update -a itron && \
    scripts/feeds install -a -p itron && \
    cp feeds/itron/rc/rc.mk package/kernel/linux/modules/rc.mk && \
    touch package/kernel/linux/Makefile && \
    cp feeds/itron/rc/kernel-patches/999-lirc_bufsize.patch target/linux/ramips/patches-4.14/ && \
    make download && cp /home/itron/itronconfig/diffconfig .config && make defconfig
CMD ["bash"]
