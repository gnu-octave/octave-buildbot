# octave-buildbot-worker

A Dockerfile to create a Buildbot Worker able to build
[GNU Octave](https://www.octave.org).

For minimal local setup of Buildbot Master and Worker, see the
["test" subdirectory](https://github.com/gnu-octave/octave-buildbot/tree/master/test).

## Docker Image

The following configuration (environment) variables are available for the
"octave-buildbot-worker" image:

- `BUILDMASTER` (default: `localhost`): The DNS or IP address of the master to
  connect to.
- `BUILDMASTER_PORT` (default: `9989`): The port of the worker protocol.
- `WORKERNAME` (default: `docker`): The name of the worker as declared in the
  master configuration.
- `WORKERPASS` (default: none): The password of the worker as declared in the
  master configuration.
- `WORKER_ENVIRONMENT_BLACKLIST` (default: `WORKERPASS`): The worker
  environment variable to remove before starting the worker.  As the
  environment variables are accessible from the build, and displayed in the
  log, it is better to remove secret variables like `WORKERPASS`.

## Start the Buildbot Worker

### 1. Pull the image and create a container from it

The values of the environment variables (described above) must be communicated
with the administrator of the Buildbot Master, here `octave.space`.

    docker pull gnuoctave/buildbot:latest-worker

    docker create \
      --env BUILDMASTER=octave.space \
      --env BUILDMASTER_PORT=9989 \
      --env WORKERNAME=worker01 \
      --env WORKERPASS=secret_password \
      --volume octave-buildbot-worker:/buildbot:Z \
      --name   octave-buildbot-worker \
      gnuoctave/buildbot:latest-worker

In the example above the name of the container and Docker volume is arbitrary.

Mounting a Docker volume is not required, but strongly suggested:
- Keep repository data and downloaded installer files when the container is
  destroyed or replaced.  This avoids heavy internet usage and build failures
  due to unresponsive servers.
- More control over the storage location.  A worker can easily use up to 70 GB
  of storage.
- The [mount option `Z`](https://docs.docker.com/storage/bind-mounts/#configure-the-selinux-label)
  is necessary, if
  [selinux](https://en.wikipedia.org/wiki/Security-Enhanced_Linux)
  is used on the system.
  If [Podman](https://podman.io/) is used instead of Docker, the
  [`exec`](https://docs.podman.io/en/latest/markdown/podman-create.1.html)
  flag should be additionally set
  `--volume octave-buildbot-worker:/buildbot:Z,exec`.

Multiple Buildbot Workers **cannot** share the same Docker volume.

### 2. Create a SSH-key

The build artifacts are copied to the Buildbot Master via `rsync` (SSH).
To enable public key authentication, a pair of private and public key (without
password) must be created.  The following command creates a private key
`id_rsa` and a public key `id_rsa.pub` in the current directory:

    ssh-keygen -q -P "" -f "./id_rsa"

Copy the private key into the Buildbot Worker container:

    docker cp ./id_rsa octave-buildbot-worker:/root/.ssh/id_rsa

and send the public key `id_rsa.pub` to the administrator of the Buildbot
Master.

### 3. Start the container

    docker start octave-buildbot-worker

### 4. Optional: Configure ccache

By default ccache is enabled and the default values are:

- `--env CCACHE_MAXSIZE=10G`: Allow usage of 10 GB of disk space.
- `--env CCACHE_DIR=/buildbot/.ccache`: The cached compiler outputs are stored
  in this directory.  This storage location is in a Docker volume, as described
  above.

To disable ccache use `--env CCACHE_DISABLE=1` for the container creation.
All settings mentioned
[in the ccache manual](https://ccache.dev/manual/3.7.11.html#_configuration)
can be passed as environment variables for the container creation.

## More information

- https://buildbot.net online version of the Buildbot documentation.
- https://github.com/buildbot/buildbot/tree/master/worker
