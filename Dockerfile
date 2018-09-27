#FROM ubuntu:bionic
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
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}


#RUN apt-get update && \
USER root
RUN apt-get update && \
    apt-get install -y man manpages \
    python3-pip \
    sudo postgresql r-base libssl-dev \
    libpq-dev parallel default-jre\
    libunwind-dev expect curl wget less htop \
    vim screen net-tools;

RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
apt-get install -y nodejs;

RUN apt install -y build-essential


RUN echo "postgres:postgres" | chpasswd
RUN perl -i -pe 's/(md5|peer)$/trust/g' /etc/postgresql/10/main/pg_hba.conf
RUN echo "jovyan ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jovyan

#RUN pg_createcluster -u postgres -g postgres 10 main

# install latest notebook
#RUN pip3 install --no-cache-dir notebook==5.*

RUN pip3 install --no-cache notebook beakerx sos sos-notebook \
quilt bash_kernel pgcli ipython-sql postgres_kernel jupyter_contrib_nbextensions \
jupyter-nbextensions-configurator RISE nbpresent;

## install R kernel for jupyter
#RUN  Rscript $HOME/rpack.R

RUN beakerx install
RUN chown -R ${NB_UID} ${HOME}
USER jovyan

# nbpresent
RUN python3 -m bash_kernel.install
RUN python3 -m sos_notebook.install
RUN jupyter contrib nbextension install --user
RUN jupyter nbextensions_configurator enable --user
RUN jupyter nbextension install nbpresent --py --overwrite --user
RUN jupyter nbextension enable nbpresent --py --user
RUN jupyter serverextension enable nbpresent --py --user
RUN jupyter-nbextension enable codefolding/main --user
RUN jupyter-nbextension install rise --py --user
RUN jupyter-nbextension enable splitcell/splitcell --user
RUN jupyter-nbextension enable hide_input/main --user
RUN jupyter-nbextension enable nbextensions_configurator/tree_tab/main --user
RUN jupyter-nbextension enable nbextensions_configurator/config_menu/main --user
RUN jupyter-nbextension enable contrib_nbextensions_help_item/main  --user
RUN jupyter-nbextension enable scroll_down/main --user
RUN jupyter-nbextension enable toc2/main --user
RUN jupyter-nbextension enable autoscroll/main  --user
RUN jupyter-nbextension enable rubberband/main --user
RUN jupyter-nbextension enable exercise2/main --user
RUN cp $HOME/common.json $HOME/.jupyter/nbconfig/common.json

# tldr
USER root
RUN npm install tldr -g
RUN tldr -u

#jdk? javahome?
RUN wget -P /usr/lib/jvm/default-java/lib https://jdbc.postgresql.org/download/postgresql-42.2.5.jar 
RUN sudo -i -u postgres /bin/bash -c "/usr/lib/postgresql/10/bin/pg_ctl -D /etc/postgresql/10/main start"
#RUN service postgresql start
RUN chown -R ${NB_UID} ${HOME}

# quilt
USER jovyan
RUN echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> $HOME/.bashrc
RUN echo "export LC_ALL=C.UTF-8" >> $HOME/.bashrc
RUN echo "export LANG=C.UTF-8" >> $HOME/.bashrc
RUN echo "export EDITOR=vim" >> $HOME/.bashrc
RUN cp $HOME/pgcli_config $HOME/.config/pgcli/config
RUN quilt install serhatcevikel/bdm_data
RUN quilt export serhatcevikel/bdm_data $HOME/data

## pgcli default options

# create imdb database
RUN service postgresql status
RUN ls /var/run/postgresql
RUN createdb -U postgres imdb
RUN gunzip -k $HOME/data/imdb/imdb.sql.gz
RUN psql imdb postgresql < $HOME/data/imdb/imdb.sql 

# Specify the default command to run

RUN cd $HOME
USER jovyan
#USER postgres
#CMD ["/usr/lib/postgresql/10/bin/pg_ctl", "-D", "/var/lib/postgresql/10/main", "-l", "logfile", "start"; "jupyter", "notebook", "--ip", "0.0.0.0"; "su", "-", "jovyan"]
#ENTRYPOINT ["sudo", "-u", "postgres", "/usr/lib/postgresql/10/bin/pg_ctl", "-D", "/etc/postgresql/10/main", "start"; "sudo", "-u", "jovyan", "jupyter", "notebook", "--notebook-dir='/home/jovyan'", "--ip", "0.0.0.0"]
#CMD service postgresql start && jupyter notebook --notebook-dir="/home/jovyan" --ip 0.0.0.0
#CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
#CMD sudo -i -u postgres /bin/bash -c "/usr/lib/postgresql/10/bin/pg_ctl -D /etc/postgresql/10/main -l /var/lib/postgresql/logfile start" && sudo -i -u jovyan /bin/bash -c "jupyter notebook --notebook-dir='/home/jovyan' --ip 0.0.0.0"
#CMD /usr/lib/postgresql/10/bin/pg_ctl -D /etc/postgresql/10/main -l /var/lib/postgresql/logfile start && jupyter notebook --notebook-dir='/home/jovyan' --ip 0.0.0.0
#CMD postgresql start
#ENTRYPOINT ["service", "postgresql", "start"]
