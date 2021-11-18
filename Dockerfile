FROM buildpack-deps:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update &&     apt-get -qq install --yes --no-install-recommends locales > /dev/null &&     apt-get -qq purge &&     apt-get -qq clean &&     rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen &&     locale-gen

ENV LC_ALL en_US.UTF-8

ENV LANG en_US.UTF-8

ENV LANGUAGE en_US.UTF-8

ENV SHELL /bin/bash

ARG NB_USER

ARG NB_UID

ENV USER ${NB_USER}

ENV HOME /home/${NB_USER}
 
RUN groupadd         --gid ${NB_UID}         ${NB_USER} &&     useradd         --comment "Default user"         --create-home         --gid ${NB_UID}         --no-log-init         --shell /bin/bash         --uid ${NB_UID}         ${NB_USER}

RUN wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key |  apt-key add - &&     DISTRO="bionic" &&     echo "deb https://deb.nodesource.com/node_14.x $DISTRO main" >> /etc/apt/sources.list.d/nodesource.list &&     echo "deb-src https://deb.nodesource.com/node_14.x $DISTRO main" >> /etc/apt/sources.list.d/nodesource.list

RUN apt-get -qq update &&     apt-get -qq install --yes --no-install-recommends        less        nodejs        unzip        > /dev/null &&     apt-get -qq purge &&     apt-get -qq clean &&     rm -rf /var/lib/apt/lists/*

EXPOSE 8888

ENV APP_BASE /srv

ENV NPM_DIR ${APP_BASE}/npm

ENV NPM_CONFIG_GLOBALCONFIG ${NPM_DIR}/npmrc

ENV CONDA_DIR ${APP_BASE}/conda

ENV NB_PYTHON_PREFIX ${CONDA_DIR}/envs/notebook

ENV NB_ENVIRONMENT_FILE /tmp/env/environment.lock

ENV KERNEL_PYTHON_PREFIX ${NB_PYTHON_PREFIX}

ENV PATH ${NB_PYTHON_PREFIX}/bin:${CONDA_DIR}/bin:${NPM_DIR}/bin:${PATH}

RUN mkdir -p ${NPM_DIR} && chown -R ${NB_USER}:${NB_USER} ${NPM_DIR}


USER ${NB_USER}

RUN npm config --global set prefix ${NPM_DIR}

USER root

ARG REPO_DIR=${HOME}

ENV REPO_DIR ${REPO_DIR}

WORKDIR ${REPO_DIR}

RUN chown ${NB_USER}:${NB_USER} ${REPO_DIR}

ENV PATH ${HOME}/.local/bin:${REPO_DIR}/.local/bin:${PATH}

ENV CONDA_DEFAULT_ENV ${KERNEL_PYTHON_PREFIX}

COPY --chown=1000:1000 src/requirements.txt ${REPO_DIR}/requirements.txt

USER ${NB_USER}

RUN ${KERNEL_PYTHON_PREFIX}/bin/pip install --no-cache-dir -r "requirements.txt"

COPY --chown=1000:1000 src/ ${REPO_DIR}

USER ${NB_USER}

RUN chmod +x postBuild

RUN ./postBuild

ENV PYTHONUNBUFFERED=1

COPY /python3-login /usr/local/bin/python3-login

COPY /repo2docker-entrypoint /usr/local/bin/repo2docker-entrypoint

COPY custom-entrypoint /urs/local/bin/custom-entrypoint

ENTRYPOINT ["/usr/local/bin/custom-entrypoint"]

CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
