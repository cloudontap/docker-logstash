#!/bin/bash

set -e

term_handler() {
  /etc/init.d/cron stop
  /etc/init.d/logstash stop
  exit 0;
}

trap 'term_handler' SIGTERM SIGKILL

ENVFILE="/tmp/context"
echo export LOGS=$LOGS > $ENVFILE
echo export REGION=$REGION >> $ENVFILE
echo export ES=$ES > $ENVFILE
echo export CACHE_AGE=$CACHE_AGE >> $ENVFILE
echo export INDEX_AGE=$INDEX_AGE >> $ENVFILE

crontab /crontab
sed -i '/pam_loginuid.so/d' /etc/pam.d/cron
/etc/init.d/cron start


/opt/gosource/startup/logstash.sh

# Add logstash as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- logstash "$@"
fi

# Run as user "logstash" if the command is "logstash"
if [ "$1" = 'logstash' ]; then
	set -- gosu logstash "$@"
fi

exec "$@" &

while true
do
  tail -f /dev/null & wait ${!}
done
