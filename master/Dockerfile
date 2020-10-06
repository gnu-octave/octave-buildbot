# Ideas from https://github.com/buildbot/buildbot/

# gnu-octave/octave-buildbot

# Please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Provides a base Ubuntu image with latest buildbot master installed.
# The master image is not optimized for size, but rather uses Ubuntu for wider
# package availability.

FROM        ubuntu:18.04
MAINTAINER  Siko1056

ENV LAST_UPDATED=2020-10-01

# Install security updates and required packages.

RUN apt-get --yes update  && \
    apt-get --yes upgrade && \
    apt-get --yes install \
      build-essential \
      curl \
      git \
      libffi-dev \
      libssl-dev \
      mercurial \
      p7zip \
      python3-dev \
      python3-pip \
      python3-setuptools \
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
    pip3 install --upgrade --no-cache-dir \
      'twisted[tls]' 'buildbot[bundle]' virtualenv buildbot-profiler \
      buildbot-wsgi-dashboards Flask

# Prepare master directory

RUN mkdir /buildbot

COPY master/defaults/* /buildbot/defaults

WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "/buildbot/defaults/start_up.sh"]
