# octave-buildbot-worker

A Dockerfile to create a Buildbot Worker able to build
[GNU Octave](https://www.octave.org).

For minimal local setup of Buildbot Master and Worker, see the
["test" subdirectory](https://github.com/siko1056/octave-buildbot/tree/master/test).

## Docker Image

Here is the list of configuration variables for the "octave-buildbot-worker"
image:

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

### 1. Create an environment file

Create a file `worker01.env` with the configuration variables above.
All values must be communicated with the administrator of the Buildbot Master,
here `octave.space`.

```
BUILDMASTER=octave.space
BUILDMASTER_PORT=9989
WORKERNAME=worker01
WORKERPASS=secret_password
```

### 2. Pull the image and create a container from it

    docker pull siko1056/octave-buildbot:latest-worker

    docker create \
      --env-file /path/to/worker01.env \
      --volume octave-buildbot-worker:/buildbot:Z \
      --name   octave-buildbot-worker \
      siko1056/octave-buildbot:latest-worker

In the example above the name of the container is arbitrary.

Mounting a Docker volume is not required, but strongly suggested:
- Keep repository data and downloaded installer files when the container is
  destroyed or replaced.  This avoids heavy internet usage and build failures
  due to unresponsive servers.
- More control over the storage location.  A worker can easily use up to 50 GB
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

### 3. Start the container

    docker start octave-buildbot-worker

### 4. Optional: Use ccache

All settings mentioned
[in the ccache manual](https://ccache.dev/manual/3.7.11.html#_configuration)
can be passed as environment variables to the container:

- `CCACHE_DISABLE=1` (default, to disable the usage of ccache) or
  `CCACHE_NODISABLE=1` (to enable the usage of ccache).  If none of the two
  settings is given, `CCACHE_DISABLE=1` will be set.
- `CCACHE_MAXSIZE` (default: `10G`): If ccache is enabled, allow usage of
  10 GB of disk space.
- `CCACHE_DIR` (default: `/buildbot/.ccache`): If ccache is enabled, the cached
  compiler outputs are stored there.  This storage location is in a Docker
  volume, as described above.

### 5. Optional: Make Buildbot worker a systemd service

If your system uses [systemd](https://systemd.io/), you can create as user
`root` the file `/etc/systemd/system/buildbot-worker.service`:

```
[Unit]
Description=BuildBot worker service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a octave-buildbot-worker
ExecStop=/usr/bin/docker stop -t 2 octave-buildbot-worker

[Install]
WantedBy=local.target
```
and enable and start the service automatically with your system.

    systemctl start  buildbot-worker.service
    systemctl enable buildbot-worker.service

## More information

- https://buildbot.net online version of the Buildbot documentation.
- https://github.com/buildbot/buildbot/tree/master/worker
