# Ideas from https://github.com/buildbot/buildbot/

# gnu-octave/octave-buildbot

# Please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Provides a base Ubuntu image with latest Buildbot Master installed.
# The Master image is not optimized for size, but rather uses Ubuntu for wider
# package availability.

FROM  ubuntu:20.04
LABEL maintainer="Kai T. Ohlhus <k.ohlhus@gmail.com>"

ENV LAST_UPDATED=2021-10-01

# Install security updates and required packages.

RUN apt-get --yes update  && \
    apt-get --yes upgrade && \
    DEBIAN_FRONTEND="noninteractive" \
    apt-get --no-install-recommends --yes install \
      build-essential \
      curl \
      git \
      libffi-dev \
      libssl-dev \
      mercurial \
      openssh-server \
      p7zip \
      python3-dev \
      python3-pip \
      python3-setuptools \
      rsync \
      subversion \
      unzip \
      zip \
      # Test runs produce a great quantity of dead grandchild processes.
      # In a non-docker environment, these are automatically reaped by init
      # (process 1), so we need to simulate that here.
      # See https://github.com/Yelp/dumb-init
      dumb-init                 && \
    apt-get --yes clean         && \
    apt-get --yes autoremove    && \
    rm -Rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc       && \
    # Install required python packages
    pip3 install --upgrade --no-cache-dir pip && \
    pip3 install --upgrade --no-cache-dir \
      'twisted[tls]' 'buildbot[bundle]' virtualenv Flask \
      buildbot-profiler buildbot-wsgi-dashboards

# Prepare master directory

RUN mkdir /buildbot && \
    mkdir /root/.ssh

COPY master/defaults/start_up.sh /buildbot/defaults/start_up.sh
COPY master/defaults/tidy_up.sh  /buildbot/defaults/tidy_up.sh
COPY master/defaults/master.cfg  /buildbot/defaults/master.cfg
COPY master/defaults/app/*       /buildbot/defaults/app/
COPY master/defaults/sshd_config /etc/ssh/sshd_config

WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "/buildbot/defaults/start_up.sh"]
