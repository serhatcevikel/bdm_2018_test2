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
    apt-get install -y python3-pip \
    sudo postgresql;

RUN echo "postgres:postgres" | chpasswd

#RUN pg_createcluster -u postgres -g postgres 10 main

# install latest notebook
RUN pip3 install --no-cache-dir notebook==5.*

#RUN pip3 install --no-cache notebook beakerx sos sos-notebook \
#quilt bash_kernel

#RUN python3 -m bash_kernel.install
#RUN python3 -m sos_notebook.install
#RUN beakerx install

# Specify the default command to run
USER root
#CMD ["/usr/lib/postgresql/10/bin/pg_ctl", "-D", "/var/lib/postgresql/10/main", "-l", "logfile", "start"; "jupyter", "notebook", "--ip", "0.0.0.0"; "su", "-", "jovyan"]
#CMD ["/usr/lib/postgresql/10/bin/pg_ctl", "-D", "/var/lib/postgresql/10/main", "-l", "logfile", "start"; "jupyter", "notebook", "--ip", "0.0.0.0"; "su", "-", "jovyan"]
CMD sudo service postgresql start && jupyter notebook --notebook-dir="/home/jovyan" --ip 0.0.0.0
#CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]


