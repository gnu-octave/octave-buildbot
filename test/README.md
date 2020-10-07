# octave-buildbot-test

With Docker and `docker-compose` installed run

    docker-compose up

If the commands succeed, you can see the Buildbot Master at
http://localhost:8010/ and the data is served at http://localhost:8000/
in your local browser with a Buildbot Worker connected.

If `docker-compose` is not available, an equivalent BASH script
`container-compose.sh` creates the same setup supporting both Docker
and Podman.

    ./container-compose.sh up

To uninstall the example, type one of:

    docker-compose down

or

    ./container-compose.sh down
