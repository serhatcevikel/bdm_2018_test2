#FROM debian:buster-20181112
FROM serhatcevikel/bigdata:hadoop1

# create user
ENV NB_USER hadoop
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

USER root

COPY . ${HOME}
RUN  chown -R ${NB_UID} ${HOME};

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
RUN tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
    && rm /tmp/hadoop.tar.gz*

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
RUN cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml
RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs

RUN mkdir /hadoop-data

ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1

ENV USER=root
ENV PATH $HADOOP_PREFIX/bin/:$PATH
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
    echo "export EDITOR=vim" >> $HOME/.bashrc;

USER ${NB_USER}
ENV SHELL /usr/bin/bash
WORKDIR ${HOME}
