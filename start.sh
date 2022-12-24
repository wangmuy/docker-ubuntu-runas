#!/bin/sh
echo 'start.sh'
mydir="$( cd `dirname $0` && pwd )"
[ -n "$WORKDIR_ROOT" ] && cd $WORKDIR_ROOT
[ -f $mydir/start_private.sh ] && . $mydir/start_private.sh
[ -f $mydir/start-user.sh ] && startScript=$mydir/start-user.sh

if [ -n "${USER_ID}" -a "${USER_ID}" != "0" -a "$UID" == "0" ]; then
  exec sudo -E -u $USER_NAME $startScript $@
else
  $startScript $@
fi
