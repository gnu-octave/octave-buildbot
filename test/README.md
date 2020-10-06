# octave-buildbot-test

With `docker-compose` installed run

    docker-compose up

If the commands succeed, you can see the Buildbot Master at
http://localhost:8010/ and the data is served at http://localhost:8000/
in your local browser with the Worker connected.

If `docker-compose` is not available, on CentOS 8 there is `podman` for
example, an equivalent BASH script `test_setup.sh` creates the same setup.

    ./test_setup.sh up

To uninstall the example, type one of:

    docker-compose down

or

    ./test_setup.sh down
