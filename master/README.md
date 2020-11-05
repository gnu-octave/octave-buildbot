# octave-buildbot-master

A Dockerfile to create a Buildbot Master managing builds of
[GNU Octave](https://www.octave.org).

For minimal local setup of Buildbot Master and Worker, see the
["test" subdirectory](https://github.com/gnu-octave/octave-buildbot/tree/master/test).

## Docker Image

The Docker image "octave-buildbot-master" is configured by `master.cfg`
contained in this repository.  This is a Buildbot configuration file, for more
information read https://docs.buildbot.net/latest/index.html

## Start the Buildbot Master

### 1. Pull the image and create a container from it

    docker pull gnuoctave/buildbot:latest-master

    docker create \
      --publish 8010:8010 \
      --publish 9989:9989 \
      --publish 9988:22 \
      --volume octave-buildbot-master:/buildbot/master:Z \
      --volume octave-buildbot-master-data:/buildbot/data:z \
      --name octave-buildbot-master \
      gnuoctave/buildbot:latest-master

In the example above the name of the container and the volumes are arbitrary.
Port 8010 is used for the web interface, port 9989 for the worker communication,
and port 9988 for `rsync` file transfers.  The port values must agree with
the `master.cfg` file.

Mounting Docker volumes is not required, but strongly suggested:
- Maintain the state and configuration (`master.cfg`) of the Buildbot Master,
  if the container is destroyed or recreated from the image.
- The [mount option `Z`](https://docs.docker.com/storage/bind-mounts/#configure-the-selinux-label)
  is necessary, if
  [selinux](https://en.wikipedia.org/wiki/Security-Enhanced_Linux)
  is used on the system.
  If [Podman](https://podman.io/) is used instead of Docker, the
  [`exec`](https://docs.podman.io/en/latest/markdown/podman-create.1.html)
  flag should be additionally set
  `--volume octave-buildbot-master:/buildbot/master:Z,exec`.

Multiple Buildbot Masters **cannot** share the same Docker volumes.

### 2. Collect all Worker's public SSH keys

Create a file `authorized_keys` and copy the public SSH keys (`id_rsa.pub`) of
all Buildbot Workers in it.  Finally copy this file in the container

    docker cp ./authorized_keys octave-buildbot-master:/root/.ssh/authorized_keys

Note, that the owner of this file inside the container must be "root" and it
may not be too permissive (`chmod 600`).

> **Note:** To use this Buildbot system without `rsync` and SSH keys,
> go back to an
> [older version of `master.cfg`](https://github.com/gnu-octave/octave-buildbot/blob/9dd6369e7962a1422ea44407bc8416f894a09790/master/defaults/master.cfg).
> But note that Buildbot's builtin
> [`FileUpload` is very slow](https://github.com/gnu-octave/octave-buildbot/issues/5).

### 2. Start the container with default configuration

    docker start octave-buildbot-master

### 3. Configure the Buildbot Master

Once the container is started with the default configuration you can modify
`master.cfg` to your needs.  To find the respective storage location of the
Docker volume, use

    docker volume inspect octave-buildbot-master
    ...
    "Mountpoint": "/var/lib/docker/storage/volumes/octave-buildbot-master/_data",
    ...

This configuration is persistent and takes effect after restarting the
container:

    docker restart octave-buildbot-master

In case of configuration errors, check `twistd.log` in the Docker volume.

### 4. Configure a web server

With the configuration of step 1, the build artifacts of the Buildbot Workers
are stored inside the Docker volume `octave-buildbot-master-data`.  This data
can be made publicly available via a web server.

For minimal local setup of Buildbot Master, Worker, and Nginx web server see the
["test" subdirectory](https://github.com/gnu-octave/octave-buildbot/tree/master/test).

## More information

- https://buildbot.net online version of the Buildbot documentation.
- https://github.com/buildbot/buildbot/tree/master/master
