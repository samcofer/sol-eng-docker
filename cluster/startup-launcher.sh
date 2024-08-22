#!/bin/bash


# Deactivate license when the process exits
deactivate() {
    echo "== Exiting =="
    rstudio-launcher stop
}
trap deactivate EXIT

# the main container process
# cannot use "exec" or the "trap" will be lost
/usr/lib/rstudio-server/bin/rstudio-launcher > /dev/stderr
