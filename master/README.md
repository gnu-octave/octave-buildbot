# octave-buildbot-master

A Dockerfile to create a Buildbot Master managing builds of
[GNU Octave](https://www.octave.org).

For minimal local setup of Buildbot Master and Worker, see the
["test" subdirectory](https://github.com/siko1056/octave-buildbot/tree/master/test).

## Docker Image

The Docker image "octave-buildbot-master" is configured by `master.cfg`
contained in this repository.  This is a Buildbot configuration file, for more
information read https://docs.buildbot.net/latest/index.html

## Start the Buildbot Master

### 1. Pull the image and create a container from it

    docker pull siko1056/octave-buildbot:latest-master

    docker create \
      --publish 8010:8010 \
      --publish 9989:9989 \
      --volume octave-buildbot-master:/buildbot/master:Z \
      --name octave-buildbot-master \
      siko1056/octave-buildbot:latest-master

In the example above the name of the container is arbitrary.  Port 8010 is used
for the web interface and port 9989 for the worker communication.  The port
values must agree with `master.cfg`.

Mounting a Docker volume is not required, but strongly suggested:
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
Multiple Buildbot Masters **cannot** share the same Docker volume.

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

### 4. Configure a web space

Depending on your needs, it can be useful to store the build results.
If the Buildbot Master runs a webserver with a public `/var/www/web.site/data`
directory, you can choose to store the build results in the container's
`/buildbot/data` directory bound to `/var/www/web.site/data` using
[file transfers](https://docs.buildbot.net/latest/manual/configuration/steps/file_transfer.html).
This binding is realized with an additional container creation parameter in
step 1:

    docker create \
      --mount type=bind,source=/var/www/web.site/data,target=/buildbot/data \
      ...

### 5. Optional: Make Buildbot master a systemd service

If your system uses [systemd](https://systemd.io/), you can create as user
`root` the file `/etc/systemd/system/buildbot-master.service`:

```
[Unit]
Description=BuildBot master service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a octave-buildbot-master
ExecStop=/usr/bin/docker stop -t 2 octave-buildbot-master

[Install]
WantedBy=local.target
```
and enable and start the service automatically with your system.

    systemctl start  buildbot-master.service
    systemctl enable buildbot-master.service

## More information

- https://buildbot.net online version of the Buildbot documentation.
- https://github.com/buildbot/buildbot/tree/master/master
