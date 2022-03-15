FROM ubuntu:20.04
MAINTAINER Zhongdi Wang <wangmuy@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Bash instead of Dash
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

# apt using ustc mirror
COPY sources.ustc.list /etc/apt/sources.list
RUN apt-get update && apt-get install -y sudo
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# git and ssh conf will be copied to new user
COPY gitconfig /root/.gitconfig
COPY ssh_config /root/.ssh/config

# chinese env
ENV LANG C.UTF-8

COPY . /scripts
ENTRYPOINT ["/scripts/docker_entrypoint.sh"]
