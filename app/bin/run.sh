#!/bin/bash

current_user_id=$(id -u)
echo "Current user id is [$current_user_id]"

DEFAULT_UID=1000
DEFAULT_GID=1000

if [[ $current_user_id -eq 0 ]]; then
    if [[ -z "${PUID}" ]]; then
        PUID=${DEFAULT_UID}
    fi
    if [[ -z "${PGID}" ]]; then
        PGID=${DEFAULT_GID}
    fi
    USER_NAME=listenbrainz-user
    GROUP_NAME=listenbrainz-group
    HOME_DIR=/home/$USER_NAME
    # handle user mode
    if [[ -n "${PUID}" && -n "${PUID}" ]]; then
        echo "Ensuring user with uid:[$PUID] gid:[$PGID] exists ...";
        ### create group if it does not exist
        if [ ! $(getent group $PGID) ]; then
            echo "Group with gid [$PGID] does not exist, creating..."
            groupadd -g $PGID $GROUP_NAME
            echo "Group [$GROUP_NAME] with gid [$PGID] created."
        else
            GROUP_NAME=$(getent group $PGID | cut -d: -f1)
            echo "Group with gid [$PGID] name [$GROUP_NAME] already exists."
        fi
        ### create user if it does not exist
        if [ ! $(getent passwd $PUID) ]; then
            echo "User with uid [$PUID] does not exist, creating..."
            useradd -g $PGID -u $PUID -M $USER_NAME
            echo "User [$USER_NAME] with uid [$PUID] created."
        else
            USER_NAME=$(getent passwd $PUID | cut -d: -f1)
            echo "user with uid [$PUID] name [$USER_NAME] already exists."
            HOME_DIR="/home/$USER_NAME"
        fi
        ### create home directory
        if [ ! -d "$HOME_DIR" ]; then
            echo "Home directory [$HOME_DIR] not found, creating."
            mkdir -p $HOME_DIR
            echo ". done."
        fi
        chown -R $PUID:$PGID $HOME_DIR
        # set ownership on volumes
        chown -R $PUID:$PGID /cache
    fi
else
    echo "Running with uid [$current_user_id]"
fi

CMD_LINE="/bin/bash"

if [[ $current_user_id -eq 0 ]]; then
    if [[ "${BACKEND}" = "pulseaudio" || -n "${PUID}" ]]; then
        echo "Running in user mode ..."
        su - $USER_NAME -c "$CMD_LINE"
    else
        echo "Running as root ..."
        eval $CMD_LINE
    fi
else
    echo "Running as uid: [$current_user_id] ..."
    eval "$CMD_LINE"
fi
