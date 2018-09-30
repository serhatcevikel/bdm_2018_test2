#FROM ubuntu:bionic --user
#FROM  postgres:10.5
FROM debian:buster-20180831

# create user
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

USER root
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER} && \
    echo "jovyan:jovyan" | chpasswd && \
    usermod -aG sudo ${NB_USER}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}

RUN apt-get install -y man manpages \
    python3-pip \
    sudo postgresql r-base libssl-dev \
    libpq-dev parallel default-jre \
    libunwind-dev expect curl libcurl4 wget less htop \
    vim screen net-tools; \
    #  apt-get update && \

    # install latest notebook and other pip packages
    pip3 install --no-cache notebook beakerx sos sos-notebook \
        quilt bash_kernel pgcli ipython-sql postgres_kernel jupyter_contrib_nbextensions; \

    #jdbc for postgresql
    wget -P /usr/lib/jvm/default-java/lib https://jdbc.postgresql.org/download/postgresql-42.2.5.jar; \

    # java env variables 
    echo "JAVA_HOME=/usr/lib/jvm/default-java" >> /etc/environment; \
    echo "CLASSPATH=$JAVA_HOME/lib/postgresql-42.2.5.jar" >> /etc/environment; \

    ## install R kernel for jupyter
    Rscript $HOME/rpack.R; \

    # rc configuration
    echo "startup_message off" >> /etc/screenrc; \
    echo "screen" >> /etc/profile; \
    
    # install node
    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
        apt install -y nodejs build-essential; \

    # change postgres password
    echo "postgres:postgres" | chpasswd; \
    
    # pg config
    perl -i -pe 's/(md5|peer)$/trust/g' /etc/postgresql/10/main/pg_hba.conf; \

    # make jovyan sudoer with no password prompt
    echo "jovyan ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jovyan; \

    # take care of sh symlink
    if [ -e /usr/bin/sh ]; \
    then \
        rm /usr/bin/sh; \
    fi; \

    ln -s /usr/bin/bash /usr/bin/sh; \
    #RUN pg_createcluster -u postgres -g postgres 10 main
    
    jupyter-nbextensions-configurator RISE nbpresent; \

    ## install beaker kernels
    beakerx install; \

    # tldr
    npm install tldr -g; \
    tldr -u; \
    
    # own home directory by user
    chown -R ${NB_UID} ${HOME}

USER ${NB_USER}

# nbpresent
RUN python3 -m bash_kernel.install; \
    python3 -m sos_notebook.install; \
    jupyter contrib nbextension install --user; \
    jupyter nbextensions_configurator enable --user; \
    jupyter nbextension install nbpresent --py --overwrite --user; \
    jupyter nbextension enable nbpresent --py --user; \
    jupyter serverextension enable nbpresent --py --user; \
    jupyter-nbextension enable codefolding/main --user; \
    jupyter-nbextension install rise --py --user; \
    jupyter-nbextension enable splitcell/splitcell --user; \
    jupyter-nbextension enable hide_input/main --user; \
    jupyter-nbextension enable nbextensions_configurator/tree_tab/main --user; \
    jupyter-nbextension enable nbextensions_configurator/config_menu/main --user; \
    jupyter-nbextension enable contrib_nbextensions_help_item/main  --user; \
    jupyter-nbextension enable scroll_down/main --user; \
    jupyter-nbextension enable toc2/main --user; \
    jupyter-nbextension enable autoscroll/main  --user; \
    jupyter-nbextension enable rubberband/main --user; \
    jupyter-nbextension enable exercise2/main --user; \
    cp $HOME/common.json $HOME/.jupyter/nbconfig/common.json; \

    # bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> $HOME/.bashrc; \
    echo "export LC_ALL=C.UTF-8" >> $HOME/.bashrc; \
    echo "export LANG=C.UTF-8" >> $HOME/.bashrc; \
    echo "export EDITOR=vim" >> $HOME/.bashrc; \
    echo "screen" >> $HOME/.bashrc; \

    ## pgcli default options
    mkdir -p $HOME/.config/pgcli; \
    cp $HOME/pgcli_config $HOME/.config/pgcli/config; \

    # quilt
    quilt install serhatcevikel/bdm_data; \
    quilt export serhatcevikel/bdm_data $HOME/data; \

    # gunzip database
    gunzip -k $HOME/data/imdb/imdb.sql.gz; \

    # run expect script for parallel
    expect ${HOME}/expect_script;

# start postgresql and create imdb database
USER root
RUN service postgresql start && \
    createdb -U postgres imdb && \
    psql imdb postgres < $HOME/data/imdb/imdb.sql; 

# Specify the default command to run
USER ${NB_USER}
ENV SHELL /usr/bin/bash
WORKDIR ${HOME}
#RUN cd ${HOME}
#USER postgres
#CMD ["/usr/lib/postgresql/10/bin/pg_ctl", "-D", "/var/lib/postgresql/10/main", "-l", "logfile", "start"; "jupyter", "notebook", "--ip", "0.0.0.0"; "su", "-", "jovyan"]
#ENTRYPOINT ["sudo", "-u", "postgres", "/usr/lib/postgresql/10/bin/pg_ctl", "-D", "/etc/postgresql/10/main", "start"; "sudo", "-u", "jovyan", "jupyter", "notebook", "--notebook-dir='/home/jovyan'", "--ip", "0.0.0.0"]
#CMD service postgresql start && jupyter notebook --notebook-dir="/home/jovyan" --ip 0.0.0.0
#CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
#CMD sudo -i -u postgres /bin/bash -c "/usr/lib/postgresql/10/bin/pg_ctl -D /etc/postgresql/10/main -l /var/lib/postgresql/logfile start" && sudo -i -u jovyan /bin/bash -c "jupyter notebook --notebook-dir='/home/jovyan' --ip 0.0.0.0"
#CMD /usr/lib/postgresql/10/bin/pg_ctl -D /etc/postgresql/10/main -l /var/lib/postgresql/logfile start && jupyter notebook --notebook-dir='/home/jovyan' --ip 0.0.0.0
#CMD postgresql start
#ENTRYPOINT ["service", "postgresql", "start"]
