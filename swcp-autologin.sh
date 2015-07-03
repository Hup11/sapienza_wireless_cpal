#!/bin/bash

TARGET_ESSID="sapienza"
PORTAL_URL="https://wifi-cont1.uniroma1.it:8003"

PROBE_TIMEOUT=5
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:36.0) Gecko/20100101 Firefox/36.0"

function log_debug {
    echo $1
}

set -e

#control if user and password are being passed
if [ -z "$CPAL_USER" -o -z "$CPAL_PASS" ]; then
    log_debug "'CPAL_USER' and 'CPAL_PASS' env variable must be set"
    exit 1
fi 

#controls if you are connected to the right AP
essid=`iwgetid -r`
if [ "$essid" != "$TARGET_ESSID" ]; then
    log_debug "Not connected to the target AP"
    exit 0;
fi

#controls if you are already logged
http_code=`curl --max-time $PROBE_TIMEOUT -s -o /dev/null -I -w "%{http_code}" http://clients3.google.com/generate_204`
if [ $http_code == 204 ]; then
    log_debug "Already logged in"
    exit 0;
fi

# actual request
echo "auth_user=$CPAL_USER&auth_pass=$CPAL_PASS&accept=Continue" | \
curl -s -o /dev/null --user-agent "$USER_AGENT" --retry 10 -d "@-" "$PORTAL_URL"

if [ $? -eq 0 ]; then
    log_debug "Login request successful sended"
    exit 0;
fi
