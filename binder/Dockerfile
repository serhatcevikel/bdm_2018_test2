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
ENV HADOOP_HOME=$HADOOP_PREFIX
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH $HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin:$PATH

RUN sed -i '/^#PubkeyAuthentication/ s/^#//' /etc/ssh/sshd_config; \
    sed -i '/^#PermitRootLogin/ s/^#//' /etc/ssh/sshd_config; \
    sed -i '/StrictHostKeyChecking/ s/^#//' /etc/ssh/ssh_config; \
    sed -i '/StrictHostKeyChecking/ s/ask/no/' /etc/ssh/ssh_config; \
    service ssh start;

RUN apt install -y \ 
        postgresql; \

    #jdbc for postgresql
    wget -P /usr/lib/jvm/default-java/lib https://jdbc.postgresql.org/download/postgresql-42.2.5.jar; \

    # change postgres password
    echo "postgres:postgres" | chpasswd; \
    
    # pg config
    perl -i -pe 's/(md5|peer)$/trust/g' /etc/postgresql/11/main/pg_hba.conf;


ENV CLASSPATH $JAVA_HOME/lib/postgresql-42.2.5.jar:$CLASSPATH
ENV PATH $PATH:/usr/lib/postgresql/11/bin

RUN chown -R ${NB_UID} $HADOOP_PREFIX && \
    chown -R ${NB_UID} /hadoop-data && \
    chmod 755 /hadoop-data;

USER ${NB_USER}
RUN cp $HOME/hadoop_config/*.xml $HADOOP_CONF_DIR; \

    mkdir -p $HOME/.ssh; \
    ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N ""; \
    cp $HOME/.ssh/id_rsa.pub $HOME/.ssh/authorized_keys; \
    hdfs namenode -format; \
    tldr -u; \
    quilt install serhatcevikel/bdm_data; \
    mkdir -p $HOME/data; \
    quilt export serhatcevikel/bdm_data $HOME/data;


# start postgresql and create imdb database
USER postgres
RUN /usr/lib/postgresql/11/bin/pg_ctl start -D /etc/postgresql/11/main/ -m smart && \
    createdb -U postgres imdb2 && \
    gunzip -c $HOME/data/imdb/imdb.sql.gz | psql imdb2 postgres && \
    #psql imdb2 postgres < $HOME/data/imdb/imdb.sql; 
    /usr/lib/postgresql/11/bin/pg_ctl stop -D /etc/postgresql/11/main/ -m smart;

# extract all files
USER ${NB_USER}
RUN rm $HOME/data/imdb/imdb.sql.gz; \
    find $HOME/data -name "*.gz" -exec gunzip {} \;

USER ${NB_USER}
ENV SHELL /usr/bin/bash
WORKDIR ${HOME}
