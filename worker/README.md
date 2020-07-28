# octave-buildbot-worker

A Dockerfile to create a Buildbot Worker able to build
[GNU Octave](https://www.octave.org).

The corresponding Buildbot Master:
https://github.com/siko1056/octave-buildbot-master

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

    docker pull siko1056/octave-buildbot-worker:latest

    docker create \
      --env-file /path/to/worker01.env \
      --name octave-buildbot-worker \
      siko1056/octave-buildbot-worker

### 3. Start the container

    docker start octave-buildbot-worker

### 4. Optional: Make Buildbot worker a systemd service

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
