FROM serhatcevikel/bigdata:hadoop02

# create user
ENV NB_USER hadoop
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

USER root

COPY . ${HOME}
RUN  chown -R ${NB_UID} ${HOME};

ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV HADOOP_VERSION 2.9.2
ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH $HADOOP_PREFIX/bin/:$PATH

USER ${NB_USER}
ENV SHELL /usr/bin/bash
WORKDIR ${HOME}
