# Ideas from
# https://github.com/buildbot/buildbot/blob/2b89992dbc4df9c5a773da862d55319f6221ddf4/worker/Dockerfile.py3
# and
# https://github.com/buildbot/buildbot/blob/2b89992dbc4df9c5a773da862d55319f6221ddf4/master/Dockerfile

# siko1056/octave-buildbot-master

# Please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Provides a base Ubuntu (18.04) image with latest buildbot master installed.
# The master image is not optimized for size, but rather uses Ubuntu for wider
# package availability.

FROM        ubuntu:18.04
MAINTAINER  Siko1056

# Install security updates and required packages.

RUN apt-get --yes update
RUN apt-get --yes upgrade
RUN apt-get --yes install \
      build-essential \
      curl \
      git \
      libffi-dev \
      libssl-dev \
      mercurial \
      python3-dev \
      python3-pip \
      python3-setuptools \
      subversion \
      # Test runs produce a great quantity of dead grandchild processes.  In a
      # non-docker environment, these are automatically reaped by init (process 1),
      # so we need to simulate that here.  See https://github.com/Yelp/dumb-init
      dumb-init
RUN apt-get --yes clean
RUN apt-get --yes autoremove
RUN rm -Rf /var/lib/apt/lists/*
RUN rm -Rf /usr/share/doc
    # Install required python packages
RUN pip3 --no-cache-dir install 'twisted[tls]' 'buildbot[bundle]' virtualenv
RUN mkdir -p /buildbot
RUN buildbot create-master -r /buildbot/master

COPY start_buildbot.sh /buildbot/start_buildbot.sh
COPY master.cfg        /buildbot/master.cfg

WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "/buildbot/start_buildbot.sh"]
