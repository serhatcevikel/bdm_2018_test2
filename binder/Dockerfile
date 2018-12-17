# postgresql, hadoop, hdfs, yarn and sqoop ready, data imported
FROM serhatcevikel/bigdata:hadoop04

# create user
ENV NB_USER hadoop
ENV NB_UID 1000
ENV HOME /home/${NB_USER}
ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV HADOOP_VERSION 2.9.2
ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_HOME=$HADOOP_PREFIX
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root

USER root

COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME} && \
    chmod +x -R ${HOME}/codes;

RUN apt install -y texlive-xetex;

# install sqoop
#ENV SQOOP_HOME=/opt/sqoop
#ENV SQOOP_VERSION=1.4.7
#ENV HADOOP_COMMON_HOME=$HADOOP_HOME/share/hadoop/common
#ENV HADOOP_HDFS_HOME=$HADOOP_HOME/share/hadoop/hdfs
#ENV HADOOP_MAPRED_HOME=$HADOOP_HOME/share/hadoop/mapreduce
#ENV HADOOP_YARN_HOME=$HADOOP_HOME/share/hadoop/yarn
#ENV PATH=$SQOOP_HOME/bin:$PATH

USER ${NB_USER}
ENV SHELL /usr/bin/bash
WORKDIR ${HOME}
