#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}
LOCAL_USER="docker-user"
LOCAL_USER_PAS="pas"

echo "###################################################################################"
echo "Starting with UID:$USER_ID, user:\"${LOCAL_USER}\", password:\"${LOCAL_USER_PAS}\""
echo "###################################################################################"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m ${LOCAL_USER}
echo "${LOCAL_USER}:${LOCAL_USER_PAS}" | chpasswd
sudo adduser ${LOCAL_USER} sudo
export HOME=/home/${LOCAL_USER}
chown ${LOCAL_USER}:${LOCAL_USER} ${HOME}
usermod -a -G root ${LOCAL_USER}    #add user to root group

exec /usr/bin/su-exec ${LOCAL_USER} "$@"
