# gnu-octave/octave-buildbot

# Please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Provides a base Ubuntu image with an openssh server and rsync installed.
# The image is not optimized for size, but rather uses Ubuntu for wider
# package availability.

FROM  ubuntu:18.04
LABEL maintainer="Kai T. Ohlhus <k.ohlhus@gmail.com>"

ENV LAST_UPDATED=2020-11-15

# Install security updates and required packages.

RUN apt-get --yes update        && \
    apt-get --yes upgrade       && \
    apt-get --yes install          \
      openssh-server               \
      rsync                     && \
    apt-get --yes clean         && \
    apt-get --yes autoremove    && \
    rm -Rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc

# Prepare master directory

RUN mkdir /buildbot/data

WORKDIR /buildbot

CMD ["/usr/sbin/sshd", "-D", "-e", "-p", "22"]
