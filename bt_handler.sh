#!/usr/bin/env bash
TARGET_MAC=$1
LOCKFILE=bt.lock

bt_lock() {
args=($1)
if [ "${args[0]}" == "$TARGET_MAC" ]
then
  if [ "${args[1]}" -lt -75 ] && [ ! -f "$LOCKFILE" ]
  then
    >"$LOCKFILE"
    echo "locked"
    loginctl lock-sessions
  fi
  if [ "${args[1]}" -gt -65 ] && [ -f "$LOCKFILE" ]
  then
    rm -f "$LOCKFILE"
    echo "unlocked"
    loginctl unlock-sessions
  fi
fi
}

export TARGET_MAC
export LOCKFILE
export -f bt_lock

./bt_disconnect.bt | grep --line-buffered "$TARGET_MAC" | xargs -r -n1 bash -c ">$LOCKFILE; /bin/systemctl suspend" &  
./bt_rssi.bt | xargs -r -n1 -I '{}' bash -c 'bt_lock "$@"' _ {}
