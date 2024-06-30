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
if [ -z "${INIT_USER}" ]; then
    INIT_USER="morgan"
fi
if [ -z "${INIT_UID}" ]; then
    INIT_UID="1000"
fi
if [ -z "${INIT_GID}" ]; then
    INIT_GID="100"
fi

# If the container started as the root user, then we have permission to refit
# the morgan user, and ensure file permissions, grant sudo rights, and such
# things before we run the command passed to start.sh as the desired user
# (INIT_USER).
#
if [ "$(id -u)" == 0 ]; then
    # Environment variables:
    # - INIT_USER: the desired username and associated home folder (default "morgan")
    # - INIT_UID: the desired user id (default "1000")
    # - INIT_GID: a group id we want our user to belong to (default "100")
    # - INIT_GROUP: a group name we want for the group (default the same with INIT_USER)
    # - GRANT_SUDO: a boolean ("1" or "yes") to grant the user sudo rights
    # - CHOWN_HOME: a boolean ("1" or "yes") to chown the user's home folder
    # - CHOWN_EXTRA: a comma-separated list of paths to chown
    # - CHOWN_HOME_OPTS / CHOWN_EXTRA_OPTS: arguments to the chown commands

    # Group configuration
    if [[ -z "${INIT_GROUP}" && -n "${INIT_GID}" ]]; then
        # Only INIT_GID is specified
        if getent group | grep -q ":${INIT_GID}:"; then
            # The group exists
            INIT_GROUP=$(getent group | grep ":100:" | cut -d: -f1)
            _log "Use existing group: '${INIT_GROUP}' (${INIT_GID})"
        else
            INIT_GROUP="${INIT_USER}"
            groupadd --gid "${INIT_GID}" "${INIT_GROUP}"
            _log "Create specified group: '${INIT_GROUP}' (${INIT_GID})"
        fi
    else
        # Both INIT_GROUP and INIT_GID specified
        if getent group "${INIT_GROUP}" &> /dev/null; then
            # Search INIT_GID from INIT_GROUP and it exists
            existing_gid=$(getent group ${INIT_GROUP} | cut -d: -f3)
            if [ "${existing_gid}" != "${INIT_GID}" ]; then
                _log "ERROR: When searching by INIT_GROUP, the group '${INIT_GROUP} (${INIT_GID})' already exists, but the specified INIT_GID '${INIT_GID}' does not match."
                exit 1
            else
                # Both informations are correct
                _log "Use existing group: '${INIT_GROUP}' (${INIT_GID})"
            fi
        elif getent group | grep -q ":${INIT_GID}:"; then
            # Search INIT_GROUP from INIT_GID and it exists
            existing_gname=$(getent group | grep ":100:" | cut -d: -f1)
            if [ "${existing_gname}" != "${INIT_GROUP}" ]; then
                _log "ERROR: When searching by INIT_GID, the group '${INIT_GROUP} (${INIT_GID})' already exists, but the specified INIT_GROUP '${INIT_GROUP}' does not match."
                exit 1
            else
                # Both informations are correct
                _log "Use existing group: '${INIT_GROUP}' (${INIT_GID})"
            fi
        else
            # The group does not exist
            # Create the desired group
            groupadd --gid "${INIT_GID}" "${INIT_GROUP}"
            _log "Create specified group: '${INIT_GROUP}' (${INIT_GID})"
        fi
    fi

    # User configuration
    if id "${INIT_USER}" &> /dev/null; then
        # Search INIT_UID by INIT_USER
        existing_uid=$(id -u "${INIT_USER}")
        if [ "${existing_uid}" != "${INIT_UID}" ]; then
            _log "ERROR: When searching by INIT_USER, the user '${INIT_USER} (${existing_uid})' already exists, but the specified INIT_UID '${INIT_UID}' does not match."
            exit 1
        else
            # Both informations are correct
            _log "Use existing user: '${INIT_USER}' (${INIT_UID})"
        fi
    else
        # Search INIT_USER by INIT_UID
        existing_uname=$(getent passwd | awk -F: -v uid="${INIT_UID}" '$3 == uid {print $1}')
        if [ -n "${existing_uname}" ]; then
            if [ "${existing_uname}" != "${INIT_USER}" ]; then
                _log "ERROR: When searching by INIT_UID, the user '${existing_uname} (${INIT_UID})' already exists, but the specified INIT_USER '${INIT_USER}' does not match."
                exit 1
            else
                # Both informations are correct
                _log "Use existing user: '${INIT_USER}' (${INIT_UID})"
            fi
        else
            # The user does not exist
            # Create the desired user
            useradd --no-log-init -m --home "/home/${INIT_USER}" --shell /bin/bash --uid "${INIT_UID}" --gid "${INIT_GID}" --groups 100 "${INIT_USER}"
            _log "Create specified user: '${INIT_USER}' (${INIT_UID})"
        fi
    fi
else
    echo "PEEEEEEE"
fi
