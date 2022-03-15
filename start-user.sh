#!/bin/bash
echo 'start-user.sh'
export HOME=/home/$USER_NAME
mydir="$( cd `dirname $0` && pwd )"
[ -n "$WORKDIR_USER" ] && cd $WORKDIR_USER
[ -f $mydir/start-user_private.sh ] && source $mydir/start-user_private.sh

# proxy
if [ $# -gt 0 ]; then
    $@
else
    /bin/bash
fi
