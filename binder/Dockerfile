#FROM ubuntu:bionic --user
#FROM  postgres:10.5
FROM debian:buster-20181112

# create user
ENV NB_USER hadoop
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

USER root
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER} && \
    echo "hadoop:hadoop" | chpasswd && \
    usermod -aG sudo ${NB_USER}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}


RUN apt update && \
    apt autoremove -y && \
    apt install -y \
    python3-pip \
    sudo libssl-dev \
    default-jdk \
    expect curl libcurl4-gnutls-dev \
    wget less \
    git \
    screen net-tools \
    gnupg vim \
    ca-certificates-java iptables nmap openssh-server; \


    # install latest notebook and other pip packages
    pip3 install --no-cache notebook sos sos-notebook \
        bash_kernel \
        jupyter_contrib_nbextensions; \

    # java env variables 
    echo "JAVA_HOME=/usr/lib/jvm/default-java" >> /etc/environment; \
    #echo "CLASSPATH=$JAVA_HOME/lib/postgresql-42.2.5.jar" >> /etc/environment; \

    # rc configuration
    echo "startup_message off" >> /etc/screenrc; \

    # make hadoop sudoer with no password prompt
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/hadoop; \

    # take care of sh symlink
    if [ -e /usr/bin/sh ]; \
    then \
        rm /usr/bin/sh; \
    fi; \

    ln -s /usr/bin/bash /usr/bin/sh; \
    # own home directory by user
    chown -R ${NB_UID} ${HOME};

# https://hub.docker.com/r/uhopper/hadoop/~/dockerfile/

ENV JAVA_HOME=/usr/lib/jvm/default-java

 
ENV HADOOP_VERSION 2.9.2
#ENV HADOOP_VERSION 3.1.1
#2.7.2
ENV HADOOP_URL https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc;

#RUN gpg --verify /tmp/hadoop.tar.gz.asc \
RUN tar -xvf /tmp/hadoop.tar.gz -C /opt/ && \
    echo "untared" && \
    rm /tmp/hadoop.tar.gz* && \
    echo "removed"

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
RUN cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml
RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs

RUN mkdir /hadoop-data

ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_HOME=$HADOOP_PREFIX
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1

RUN chown -R hadoop:hadoop $HADOOP_PREDIX && \
    chown -R hadoop:hadoop /hadoop-data && \
    chmod 755 /hadoop-data; \

    sed -i '/^#PubkeyAuthentication/ s/^#//' /etc/ssh/sshd_config; \
    sed -i '/^#PermitRootLogin/ s/^#//' /etc/ssh/sshd_config; \
    sed -i '/StrictHostKeyChecking/ s/^#//' /etc/ssh/ssh_config; \
    sed -i '/StrictHostKeyChecking/ s/ask/no/' /etc/ssh/ssh_config; \

    cp $HOME/hadoop_config/*.xml $HADOOP_CONF_DIR

ENV USER=root
ENV PATH $HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin:$PATH
###

USER ${NB_USER}

RUN python3 -m bash_kernel.install; \
    python3 -m sos_notebook.install; \
    jupyter contrib nbextension install --user; \
    jupyter nbextensions_configurator enable --user; \
    jupyter-nbextension enable toc2/main --user; \
    jupyter-nbextension enable autoscroll/main  --user; \
    cp $HOME/binder/common.json $HOME/.jupyter/nbconfig/common.json; \

    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> $HOME/.bashrc; \
    echo "export LC_ALL=C.UTF-8" >> $HOME/.bashrc; \
    echo "export LANG=C.UTF-8" >> $HOME/.bashrc; \
    echo "export EDITOR=vim" >> $HOME/.bashrc; \

    mkdir -p $HOME/.ssh; \
    ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""; \
    cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys; \

USER ${NB_USER}
ENV SHELL /usr/bin/bash
WORKDIR ${HOME}
