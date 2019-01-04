# postgresql, hadoop, hdfs, yarn pig, hive and sqoop ready, data imported
FROM serhatcevikel/bigdata:hadoop05

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
ENV HIVE_CONF_DIR=$HIVE_HOME/conf
ENV HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$HIVE_HOME/lib/*

USER root

COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME} && \
    chmod +x -R ${HOME}/codes;

RUN apt install -y \
    openjdk-8-jdk; \

    # change java version
    rm /usr/lib/jvm/default-java; \
    ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/default-java; \
    rm /etc/alternatives/java; \
    ln -s /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /etc/alternatives/java;


USER ${NB_USER}
RUN cp ${HOME}/hive_config/* $HIVE_HOME/conf/ && \
    schematool -initSchema -dbType derby && \
    ln -s $HIVE_HOME/lib/derby-10.10.2.0.jar $SQOOP_HOME/lib/derby-10.10.2.0.jar; \
    ln -s $HIVE_HOME/lib/hive-exec.jar $SQOOP_HOME/lib/hive-exec.jar;

USER ${NB_USER}
ENV SHELL /usr/bin/bash
WORKDIR ${HOME}


