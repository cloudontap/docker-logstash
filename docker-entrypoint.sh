#!/bin/bash

set -e
pid=0

term_handler() {
  /etc/init.d/cron stop
  kill -SIGTERM "$pid"
  wait "$pid"
  exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM

ENVFILE="/tmp/context"
echo export LOGS=$LOGS > $ENVFILE
echo export REGION=$REGION >> $ENVFILE
echo export ES=$ES >> $ENVFILE
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
pid="$!"

while true
do
  tail -f /dev/null & wait ${!}
done
