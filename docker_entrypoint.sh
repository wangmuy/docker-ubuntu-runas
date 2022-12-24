#!/bin/bash
set -x

# This script designed to be used a docker ENTRYPOINT "workaround" missing docker
# feature discussed in docker/docker#7198, allow to have executable in the docker
# container manipulating files in the shared volume owned by the USER_ID:GROUP_ID.
#
# It creates a user named `$USER_NAME` with selected USER_ID and GROUP_ID (or
# 1000 if not specified).

# Example:
#
#  docker run -ti -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) imagename bash
#

# Reasonable defaults if no USER_ID/GROUP_ID environment variables are set.
if [ -z ${USER_ID+x} ]; then USER_ID=1000; fi
if [ -z ${GROUP_ID+x} ]; then GROUP_ID=1000; fi
if [ -z ${USER_NAME+x} ]; then USER_NAME="duser"; fi
duser_byid="$(id -nu $USER_ID 2>/dev/null)"
[ -n "$duser_byid" ] && USER_NAME=$duser_byid
old_duser="$(id -u $USER_NAME 2>/dev/null)"
[ -n "$old_duser" ] && USER_ID=$old_duser
id -g $USER_NAME > /dev/null 2>&1 && GROUP_ID=$(id -g $USER_NAME)
export USER_ID GROUP_ID USER_NAME

if [ -z "$old_duser" -a "${USER_ID}" != "0" -a "$UID" == "0" ]; then
  msg="docker_entrypoint: Creating user UID/GID [$USER_ID/$GROUP_ID]" && echo $msg
  groupadd -g $GROUP_ID -r $USER_NAME && \
  useradd -u $USER_ID --create-home -r -g $USER_NAME $USER_NAME
  echo "$msg - done"

  msg="docker_entrypoint: Copying .gitconfig and .ssh/config to new user home" && echo $msg
  [ -f /root/.gitconfig ] && cp /root/.gitconfig /home/$USER_NAME/.gitconfig && \
  chown $USER_NAME:$USER_NAME /home/$USER_NAME/.gitconfig
  mkdir -p /home/$USER_NAME/.ssh
  [ -f /root/.ssh/config ] && cp /root/.ssh/config /home/$USER_NAME/.ssh/config
  chown $USER_NAME:$USER_NAME -R /home/$USER_NAME/.ssh && \
  echo "$msg - done"

  echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  echo "entrypoint script done!"
fi

echo "entrypoint going exec..."
# Default to 'bash' if no arguments are provided
args="$@"
if [ -z "$args" ]; then
  args="bash"
fi
exec /scripts/start.sh $@

