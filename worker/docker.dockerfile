# Ideas from https://github.com/buildbot/buildbot/

# gnu-octave/octave-buildbot

# Please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Provides a base Ubuntu image with latest Buildbot Worker installed.
# The worker image is not optimized for size, but rather uses Ubuntu for wider
# package availability.

FROM  ubuntu:18.04
LABEL maintainer="Kai T. Ohlhus <k.ohlhus@gmail.com>"

ENV LAST_UPDATED=2021-01-01

# Install security updates and required packages.

RUN apt-get --yes update  && \
    apt-get --yes upgrade && \
    apt-get --yes install \
      apt-transport-https \
      build-essential \
      ca-certificates \
      curl \
      git \
      gnupg-agent \
      mercurial \
      subversion \
      python3-dev \
      libffi-dev \
      libssl-dev \
      python3-setuptools \
      python3-pip \
      software-properties-common \
      # Test runs produce a great quantity of dead grandchild processes.
      # In a non-docker environment, these are automatically reaped by init
      # (process 1), so we need to simulate that here.
      # See https://github.com/Yelp/dumb-init
      dumb-init                 && \
    # Install required python packages
    pip3 install --upgrade --no-cache-dir \
      'twisted[tls]' 'buildbot[bundle]' virtualenv && \
    # Add Docker’s official GPG key and repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"                   && \
    apt-get --yes update        && \
    apt-get --yes install          \
      docker-ce                    \
      docker-ce-cli                \
      containerd.io             && \
    apt-get --yes clean         && \
    apt-get --yes autoremove    && \
    rm -Rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc


# Prepare worker directory

RUN mkdir /buildbot && \
    mkdir /root/.ssh

COPY worker/buildbot.tac /buildbot/buildbot.tac

WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "twistd", "--pidfile=", "-ny", "buildbot.tac"]
