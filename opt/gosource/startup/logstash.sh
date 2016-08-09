#!/bin/bash

# Stuff that should already be in the image
GOSOURCE_STARTUP=/opt/gosource/startup

# Create the directory tree for use by the logstash container - better if mounted on the host 
# Also means it is easy to see what configuration the container is running with
LOGSTASH_ROOT=/product/logstash
LOGSTASH_CACHE=${LOGSTASH_ROOT}/cache
LOGSTASH_GEOIP=${LOGSTASH_ROOT}/geoip
LOGSTASH_S3=${LOGSTASH_ROOT}/s3
mkdir --parents --mode=777 ${LOGSTASH_CACHE}
mkdir --parents --mode=777 ${LOGSTASH_S3}
mkdir --parents --mode=755 ${LOGSTASH_GEOIP}

# Copy in the specific config from the image
cp -rp $GOSOURCE_STARTUP/logstash/* $LOGSTASH_ROOT

# Do an initial run of the geoip and awslogs scripts
$GOSOURCE_STARTUP/geoip.sh
$GOSOURCE_STARTUP/awslogs.sh

# Generate the logstash configuration file
VARIABLES=""
VARIABLES="$VARIABLES -v ROOT=$LOGSTASH_ROOT"
VARIABLES="$VARIABLES -v PRODUCT=$PRODUCT"
VARIABLES="$VARIABLES -v CONTAINER=$CONTAINER"
VARIABLES="$VARIABLES -v LOGS=$LOGS"
VARIABLES="$VARIABLES -v REGION=$REGION"
VARIABLES="$VARIABLES -v ES=$ES"

# Generate the logstash configuration for loading data to elasticsearch
java -jar $GOSOURCE_STARTUP/gsgen.jar -i logstash.ftl -d $LOGSTASH_ROOT -o $LOGSTASH_ROOT/logstash.conf $VARIABLES

VARIABLES=""
VARIABLES="$VARIABLES -v SHARDS=${SHARDS:-1}"
VARIABLES="$VARIABLES -v REPLICAS=${REPLICAS:-1}"

# Generate the logs index mapping template
java -jar $GOSOURCE_STARTUP/gsgen.jar -i logs_template.ftl -d $LOGSTASH_ROOT -o $LOGSTASH_ROOT/logs_template.json $VARIABLES

# Set the last modified date for s3 based logs back a year to pick up any files that have been missed
# Occasionally the current version of the logstash s3 input plugin misses files. If this gets fixed, then 
# the window could be tightening but it doesn't hurt to leave it broad as files are deleted once processed.
echo $(date --utc "+%Y-%m-%d 00:00:00 +0000" -d "1 year ago") > ${LOGSTASH_S3}/.since_db_docker
chmod 777 ${LOGSTASH_S3}/.since_db_docker
#
