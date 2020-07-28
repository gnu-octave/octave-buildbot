# octave-buildbot-master

A Dockerfile to create a Buildbot Master managing builds of
[GNU Octave](https://www.octave.org).

The corresponding Buildbot Worker:
https://github.com/siko1056/octave-buildbot-worker

## Docker Image

The Docker image "octave-buildbot-master" is configured by `master.cfg`
contained in this repository.  This is a Buildbot configuration file, for more
information read https://docs.buildbot.net/latest/index.html


## Start the Buildbot Master

### 1. Configuration

Copy `master.cfg` from this repository and configure it to your needs.

### 2. Pull the image and create a container from it

    docker pull siko1056/octave-buildbot-master:latest

    docker create \
      --mount type=volume,source=octave-buildbot-master,target=/buildbot/master \
      --publish 8010:8010 \
      --publish 9989:9989 \
      --name octave-buildbot-master \
      siko1056/octave-buildbot-master

### 3. Start the container

    docker start octave-buildbot-master

### 4. Optional: Make Buildbot master a systemd service

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
