# octave-buildbot-test

The BASH script `test_setup.sh` creates a minimal local setup of Buildbot
Master and Worker.  As user who is allowed to interact with Docker, you can
create the complete example with:

    ./test_setup.sh all

If the commands succeed, you can see the Buildbot Master at
http://localhost:8010/ in your local browser with the Worker connected.

You can create the Buildbot Master and Worker separately:

    ./test_setup.sh master
    ./test_setup.sh worker

To uninstall the example from Docker, type:

    ./test_setup.sh cleanup
