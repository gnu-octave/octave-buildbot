# octave-buildbot-test

With Docker and `docker-compose` installed run

    docker-compose up

If the commands succeed, you can open the **Buildbot Master** web interface at
http://localhost:8010/ and the data is served by a local **Nginx webserver** at
http://localhost:8000/ in your local browser with a **Buildbot Worker** connected.

If `docker-compose` is not available, an equivalent BASH script
`container-compose.sh` creates the same setup supporting both Docker
and Podman.

    ./container-compose.sh up

After the container creation, the bash script `create-and-copy-ssh-keys.sh`
should be run to create and copy a SSH private key into the Docker container
of the Buildbot Worker and to authorize the Worker with it's public key at
the Buildbot master.

To uninstall the whole example, type one of:

    docker-compose down

or

    ./container-compose.sh down
