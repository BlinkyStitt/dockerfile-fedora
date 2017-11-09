#
# Fedora container with helper scripts for installing packages
#
# todo: this is pretty much identical to bwstitt/library-ubuntu
#
FROM fedora:26

RUN set -eux; \
    \
    groupadd -g 911 abc; \
    useradd -m -s /bin/bash -g 911 -u 911 abc

COPY docker-dnf-install.sh /usr/local/sbin/docker-install

RUN docker-install bash
