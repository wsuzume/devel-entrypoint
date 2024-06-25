#!/bin/bash
# This code partially includes the start.sh from the official Jupyter notebook image.

# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Copyright (c) Yoshinobu Ogura (Josh Nobus / @wsuzume).
# Distributed under the terms of the Modified BSD License.

set -e

# The _log function is used for everything this script wants to log.
# It will always log errors and warnings but can be silenced for other messages
# by setting the INIT_SCRIPT_QUIET environment variable.
_log () {
    if [[ "$*" == "ERROR:"* ]] || [[ "$*" == "WARNING:"* ]] || [[ "${INIT_SCRIPT_QUIET}" == "" ]]; then
        echo "$@"
    fi
}
_log "Entered init.sh with args:" "$@"

# Default to starting bash if no command was specified
if [ $# -eq 0 ]; then
    cmd=( "bash" )
else
    cmd=( "$@" )
fi

# If the container started as the root user, then we have permission to refit
# the morgan user, and ensure file permissions, grant sudo rights, and such
# things before we run the command passed to start.sh as the desired user
# (USER).
#
if [ "$(id -u)" == 0 ]; then
    echo "WHEEEEEEEE"
else
    echo "PEEEEEEE"
fi
