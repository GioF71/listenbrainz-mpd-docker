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

# minimum config check
if [[ -z "${LISTENBRAINZ_TOKEN}" ]] && [[ -z "${LISTENBRAINZ_TOKEN_FILE}" ]]; then
    echo "Both LISTENBRAINZ_TOKEN and LISTENBRAINZ_TOKEN_FILE have not been specified, existing."
    exit 1
fi

CONFIG_FILE=/tmp/config.toml
if [ -f $CONFIG_FILE ]; then
    echo "Removing existing configuration file."
    rm $CONFIG_FILE
fi

# Create configuration file

## submission section

echo "[submission]" > $CONFIG_FILE

if [[ -n "${LISTENBRAINZ_TOKEN}" ]]; then
    echo "token = \"${LISTENBRAINZ_TOKEN}\"" >> $CONFIG_FILE
elif [[ -n "${LISTENBRAINZ_TOKEN_FILE}" ]]; then
    echo "token_file = \"${LISTENBRAINZ_TOKEN_FILE}\"" >> $CONFIG_FILE
else
    echo "Token not available"
    exit 1
fi

### cache file
cache_enabled=0
cache_directory="/cache"
cache_file=/cache/cache.db

if [ -w $cache_directory ]; then
    if [[ -z "${ENABLE_CACHE}" ]] || \
        [[ "${ENABLE_CACHE^^}" == "Y" ]] || \
        [[ "${ENABLE_CACHE^^}" == "YES" ]] || \
        [[ "${ENABLE_CACHE^^}" == "TRUE" ]]; then
        cache_enabled=1
        echo "Caching enabled."
        echo "enable_cache = true" >> $CONFIG_FILE
        echo "cache_file = \"$cache_file\"" >> $CONFIG_FILE
    elif [[ "${ENABLE_CACHE^^}" != "N" ]] && \
        [[ "${ENABLE_CACHE^^}" == "NO" ]] && \
        [[ "${ENABLE_CACHE^^}" == "FALSE" ]]; then
        echo "Invalid ENABLE_CACHE=[${ENABLE_CACHE}]"
        exit 1
    fi
else
    # if we are root, we can change permissions
    if [[ $current_user_id -eq 0 ]]; then
        echo "Changing permissions for [$cache_directory]"
        chown -R $PUID:$PGID $cache_directory
        echo ". done."
    else
        # disabled because it's not writable
        echo "Cache directory [${cache_directory}] is not writable, will be disabled"
    fi
fi

if [ $cache_enabled -eq 0 ]; then
    echo "Caching is disabled"
    echo "enable_cache = false" >> $CONFIG_FILE
else
    # create file if missing
    if [ ! -f $cache_file ]; then
        echo "Creating cache file ..."
        sqlite3 $cache_file "VACUUM;"
        echo ". done"
    fi
    # set ownership if possible
    if [[ $current_user_id -eq 0 ]]; then
        echo "Changing permissions for [$cache_file]"
        chown $PUID:$PGID $cache_file
        echo ". done."
    fi
fi

## mpd section
echo "[mpd]" >> $CONFIG_FILE

if [[ -n "${MPD_ADDRESS}" ]]; then
    echo "address = \"${MPD_ADDRESS}\"" >> $CONFIG_FILE
fi

if [[ -n "${MPD_PASSWORD}" ]]; then
    echo "password = \"${MPD_PASSWORD}\"" >> $CONFIG_FILE
elif [[ -n "${MPD_PASSWORD_FILE}" ]]; then
    echo "password_file = \"${MPD_PASSWORD_FILE}\"" >> $CONFIG_FILE
fi

cat $CONFIG_FILE

CMD_LINE="listenbrainz-mpd -c $CONFIG_FILE"
echo "CMD_LINE=[${CMD_LINE}]"

if [[ $current_user_id -eq 0 ]]; then
    echo "Running in user mode uid [$PUID] gid [$PGID] ..."
    su - $USER_NAME -c "$CMD_LINE"
else
    echo "Running as uid: [$current_user_id] ..."
    eval "$CMD_LINE"
fi