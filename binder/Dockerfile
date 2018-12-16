# hadoop and postgresql configuration ok
FROM serhatcevikel/bigdata:hadoop03

# create user
ENV NB_USER hadoop
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

USER root

COPY . ${HOME}
RUN  chown -R ${NB_UID} ${HOME};

USER ${NB_USER}
ENV SHELL /usr/bin/bash
WORKDIR ${HOME}
