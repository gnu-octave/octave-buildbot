# Ideas from https://github.com/buildbot/buildbot/

# siko1056/octave-buildbot

# Please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Provides a base Ubuntu image with latest buildbot worker installed.
# The worker image is not optimized for size, but rather uses Ubuntu for wider
# package availability.

FROM        ubuntu:18.04
MAINTAINER  Siko1056

ENV LAST_UPDATED=2020-08-05

# Install security updates and required packages.

RUN apt-get --yes update  && \
    apt-get --yes upgrade && \
    apt-get --yes install \
      autoconf \
      automake \
      bison \
      build-essential \
      ccache \
      clang \
      cmake \
      dbus \
      doxygen \
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
      librsvg2-bin \
      libseccomp-dev \
      libssl-dev \
      libsndfile1-dev \
      libtool \
      libxft-dev \
      lpr \
      lzip \
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
      dumb-init                 && \
    apt-get --yes clean         && \
    apt-get --yes autoremove    && \
    rm -Rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc       && \
    # Install required python packages
    pip3 install --upgrade --no-cache-dir \
      'twisted[tls]' 'buildbot[bundle]' virtualenv

# Install Sundials

RUN SUNDIALS_VERSION=5.3.0  && \
    mkdir -p /tmp/build     && \
    cd       /tmp/build     && \
    wget -q "https://computation.llnl.gov/projects/sundials/download/sundials-${SUNDIALS_VERSION}.tar.gz" && \
    tar -xf sundials-${SUNDIALS_VERSION}.tar.gz  && \
    cd      sundials-${SUNDIALS_VERSION}         && \
    mkdir build  && \
    cd    build  && \
    cmake                                          \
      -DEXAMPLES_ENABLE_C=OFF                      \
      -DKLU_ENABLE=ON                              \
      -DKLU_INCLUDE_DIR=/usr/include/suitesparse   \
      -DKLU_LIBRARY_DIR=/usr/lib/x86_64-linux-gnu  \
      -DBUILD_ARKODE=OFF                           \
      -DBUILD_CVODE=OFF                            \
      -DBUILD_CVODES=OFF                           \
      -DBUILD_IDA=ON                               \
      -DBUILD_IDAS=OFF                             \
      -DBUILD_KINSOL=OFF                           \
      -DBUILD_CPODES=OFF                           \
      -DCMAKE_INSTALL_PREFIX=/usr                  \
      ..              && \
    make -j4          && \
    make install      && \
    rm -rf /tmp/build

# Prepare worker directory

RUN mkdir /buildbot

COPY worker/buildbot.tac /buildbot/buildbot.tac

WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "twistd", "--pidfile=", "-ny", "buildbot.tac"]
