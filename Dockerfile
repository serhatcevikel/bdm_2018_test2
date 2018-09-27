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
    libpq-dev parallel \
    libunwind-dev expect;

RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - \
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

RUN jupyter contrib nbextension install
RUN jupyter nbextensions_configurator enable

RUN python3 -m bash_kernel.install
RUN python3 -m sos_notebook.install
RUN beakerx install

# nbpresent
RUN jupyter nbextension install nbpresent --py --overwrite
RUN jupyter nbextension enable nbpresent --py
RUN jupyter serverextension enable nbpresent --py
RUN jupyter-nbextension enable codefolding/main
RUN jupyter-nbextension install rise --py --sys-prefix
RUN jupyter-nbextension enable splitcell/splitcell
RUN jupyter-nbextension enable hide_input/main
RUN jupyter-nbextension enable nbextensions_configurator/tree_tab/main
RUN jupyter-nbextension enable nbextensions_configurator/config_menu/main
RUN jupyter-nbextension enable contrib_nbextensions_help_item/main 
RUN jupyter-nbextension enable scroll_down/main
RUN jupyter-nbextension enable toc2/main
RUN jupyter-nbextension enable autoscroll/main 
RUN jupyter-nbextension enable rubberband/main
RUN jupyter-nbextension enable exercise2/main

USER jovyan
RUN cp $HOME/common.json $HOME/.jupyter/nbconfig/common.json

# quilt
RUN quilt install serhatcevikel/bdm_data
RUN quilt export serhatcevikel/bdm_data $HOME/data

# tldr
RUN npm install tldr
RUN tldr -u

# Specify the default command to run

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
