# Copied from
# https://github.com/buildbot/buildbot/blob/2b89992dbc4df9c5a773da862d55319f6221ddf4/worker/Dockerfile.py3

# siko1056/octave-buildbot-worker

# Please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Provides a base Ubuntu (18.04) image with latest buildbot worker installed.
# The worker image is not optimized for size, but rather uses Ubuntu for wider
# package availability.

FROM        ubuntu:18.04
MAINTAINER  Siko1056

# Install security updates and required packages.

RUN apt-get --yes update
RUN apt-get --yes upgrade
RUN apt-get --yes install \
      autoconf \
      automake \
      bison \
      build-essential \
      clang \
      cmake \
      dbus \
      epstool \
      flex \
      g++ \
      gcc \
      gfortran \
      git \
      gnuplot \
      gperf \
      gzip \
      icoutils \
      less \
      libarpack2-dev \
      libblas-dev \
      libcurl4-gnutls-dev \
      liblapack-dev \
      libpcre3-dev \
      libffi-dev \
      libfftw3-dev \
      libfltk1.3-dev \
      libfontconfig1-dev \
      libfreetype6-dev \
      libgl1-mesa-dev \
      libgl2ps-dev \
      libglpk-dev \
      libgmp-dev \
      libgpgme11-dev \
      libgraphicsmagick++1-dev \
      libhdf5-serial-dev \
      libopenblas-dev \
      libosmesa6-dev \
      libqhull-dev \
      libqrupdate-dev \
      libqscintilla2-qt5-dev \
      libqt5opengl5-dev \
      libreadline-dev \
      libsuitesparse-dev \
      libsundials-dev \
      librsvg2-bin \
      libseccomp-dev \
      libssl-dev \
      libsndfile1-dev \
      libtool \
      libxft-dev \
      lpr \
      make \
      mercurial \
      openjdk-11-jdk \
      perl \
      pkg-config \
      portaudio19-dev \
      pstoedit \
      python3-dev \
      python3-pip \
      python3-setuptools \
      qtbase5-dev \
      qttools5-dev \
      qttools5-dev-tools \
      subversion \
      tar \
      texinfo \
      texlive \
      texlive-generic-recommended \
      transfig \
      unzip \
      wget \
      zlib1g-dev \
      zip \
      # Test runs produce a great quantity of dead grandchild processes.
      # In a non-docker environment, these are automatically reaped by init
      # (process 1), so we need to simulate that here.
      # See https://github.com/Yelp/dumb-init
      dumb-init
RUN apt-get --yes clean
RUN apt-get --yes autoremove
RUN rm -Rf /var/lib/apt/lists/*
RUN rm -Rf /usr/share/doc

# Install required python packages

RUN pip3 --no-cache-dir install 'twisted[tls]' 'buildbot[bundle]' virtualenv

# Prepare worker directory

RUN mkdir /buildbot
RUN useradd --create-home --shell /bin/bash buildbot

COPY buildbot.tac /buildbot/buildbot.tac

RUN chown -R buildbot /buildbot

USER buildbot
WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "twistd", "--pidfile=", "-ny", "buildbot.tac"]
