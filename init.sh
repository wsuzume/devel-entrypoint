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

# Default user settings
if [ -z "${USER}" ]; then
    USER="morgan"
fi
if [ -z "${UID}" ]; then
    UID="1000"
fi
if [ -z "${GID}" ]; then
    GID="100"
fi

# If the container started as the root user, then we have permission to refit
# the morgan user, and ensure file permissions, grant sudo rights, and such
# things before we run the command passed to start.sh as the desired user
# (USER).
#
if [ "$(id -u)" == 0 ]; then
    # Environment variables:
    # - USER: the desired username and associated home folder (default "morgan")
    # - UID: the desired user id (default "1000")
    # - GID: a group id we want our user to belong to (default "100")
    # - GROUP: a group name we want for the group (default the same with USER)
    # - GRANT_SUDO: a boolean ("1" or "yes") to grant the user sudo rights
    # - CHOWN_HOME: a boolean ("1" or "yes") to chown the user's home folder
    # - CHOWN_EXTRA: a comma-separated list of paths to chown
    # - CHOWN_HOME_OPTS / CHOWN_EXTRA_OPTS: arguments to the chown commands

    # Group configuration
    if [[ -z "${GROUP}" && -n "${GID}" ]]; then
        # Only GID is specified
        if getent group | grep -q ":${GID}:"; then
            # The group exists
            GROUP=$(getent group | grep ":100:" | cut -d: -f1)
            _log "Use existing group: '${GROUP}' (${GID})"
        else
            GROUP="${USER}"
            groupadd --gid "${GID}" "${GROUP}"
            _log "Create specified group: '${GROUP}' (${GID})"
        fi
    else
        # Both GROUP and GID specified
        if getent group "${GROUP}" &> /dev/null; then
            # Search GID from GROUP and it exists
            existing_gid=$(getent group ${GROUP} | cut -d: -f3)
            if [ "${existing_gid}" != "${GID}" ]; then
                _log "ERROR: When searching by GROUP, the group '${GROUP} (${GID})' already exists, but the specified GID '${GID}' does not match."
                exit 1
            else
                # Both informations are correct
                _log "Use existing group: '${GROUP}' (${GID})"
            fi
        elif getent group | grep -q ":${GID}:"; then
            # Search GROUP from GID and it exists
            existing_gname=$(getent group | grep ":100:" | cut -d: -f1)
            if [ "${existing_gname}" != "${GROUP}" ]; then
                _log "ERROR: When searching by GID, the group '${GROUP} (${GID})' already exists, but the specified GROUP '${GROUP}' does not match."
                exit 1
            else
                # Both informations are correct
                _log "Use existing group: '${GROUP}' (${GID})"
            fi
        else
            # The group does not exist
            # Create the desired group
            groupadd --gid "${GID}" "${GROUP}"
            _log "Create specified group: '${GROUP}' (${GID})"
        fi
    fi

    # User configuration
    if id "${USER}" &> /dev/null; then
        # Search UID by USER
        existing_uid=$(id -u "${USER}")
        if [ "${existing_uid}" != "${UID}" ]; then
            _log "ERROR: When searching by USER, the user '${USER} (${UID})' already exists, but the specified UID '${UID}' does not match."
            exit 1
        else
            # Both informations are correct
            _log "Use existing user: '${USER}' (${UID})"
        fi
    else
        # Search USER by UID
        existing_uname = $(getent passwd | awk -F: -v uid="${UID}" '$3 == uid {print $1}')
        if [ -n "{$existing_uname}" ]; then
            if [ "${existing_uname}" != "${USER}" ]; then
                _log "ERROR: When searching by UID, the user '${USER} (${UID})' already exists, but the specified USER '${USER}' does not match."
                exit 1
            else
                # Both informations are correct
                _log "Use existing user: '${USER}' (${UID})"
            fi
        else
            # The user does not exist
            # Create the desired user
            useradd --no-log-init -m --home "/home/${USER}" --shell /bin/bash --uid "${UID}" --gid "${GID}" --groups 100 "${USER}"
            _log "Create specified user: '${USER}' (${UID})"
        fi
    fi
else
    echo "PEEEEEEE"
fi
