# Ideas from https://github.com/buildbot/buildbot/

# gnu-octave/octave-buildbot

# Please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Provides a base Ubuntu image with latest Buildbot Worker installed.
# The worker image is not optimized for size, but rather uses Ubuntu for wider
# package availability.

FROM  gnuoctave/octave:build-octave-6
LABEL maintainer="Kai T. Ohlhus <k.ohlhus@gmail.com>"

ENV LAST_UPDATED=2020-11-01

# Install security updates and required packages.

RUN apt-get --yes update  && \
    apt-get --yes upgrade && \
    apt-get --yes install \
      ccache \
      doxygen \
      graphviz \
      libffi-dev \
      lzip \
      p7zip \
      python3-dev \
      python3-pip \
      python3-setuptools \
      rsync \
      subversion \
      xvfb \
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
      'twisted[tls]' 'buildbot[bundle]' virtualenv


# Prepare ccache

RUN ln -s /usr/bin/ccache /usr/local/bin/gcc && \
    ln -s /usr/bin/ccache /usr/local/bin/g++ && \
    ln -s /usr/bin/ccache /usr/local/bin/c++ && \
    ln -s /usr/bin/ccache /usr/local/bin/cc  && \
    mkdir -p /root/.ccache                   && \
    echo "max_size = 10.0G\ncache_dir = /buildbot/.ccache" \
      > /root/.ccache/ccache.conf

# Prepare worker directory

RUN mkdir /buildbot && \
    mkdir /root/.ssh

COPY worker/buildbot.tac /buildbot/buildbot.tac

WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "twistd", "--pidfile=", "-ny", "buildbot.tac"]
