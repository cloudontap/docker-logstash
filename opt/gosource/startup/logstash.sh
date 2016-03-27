#!/bin/bash

# Stuff that should already be in the image
GOSOURCE_STARTUP=/opt/gosource/startup

# Create the directory tree for use by the logstash container - better if mounted on the host 
# Also means it is easy to see what configuration the container is running with
LOGSTASH_ROOT=/project/logstash
LOGSTASH_CACHE=${LOGSTASH_ROOT}/cache
LOGSTASH_GEOIP=${LOGSTASH_ROOT}/geoip
mkdir --parents --mode=777 ${LOGSTASH_CACHE}
mkdir --parents --mode=755 ${LOGSTASH_GEOIP}

# Copy in the specific config from the image
cp -rp $GOSOURCE_STARTUP/logstash/* $LOGSTASH_ROOT

# Do an initial run of the geoip and awslogs scripts
$GOSOURCE_STARTUP/geoip.sh
$GOSOURCE_STARTUP/awslogs.sh

# Generate the logstash configuration file
VARIABLES=""
VARIABLES="$VARIABLES -v ROOT=$LOGSTASH_ROOT"
VARIABLES="$VARIABLES -v PROJECT=$PROJECT"
VARIABLES="$VARIABLES -v CONTAINER=$CONTAINER"
VARIABLES="$VARIABLES -v LOGS=$LOGS"
VARIABLES="$VARIABLES -v REGION=$REGION"
VARIABLES="$VARIABLES -v ES=$ES"

# Generate the logstash configuration for loading data to elasticsearch
java -jar $GOSOURCE_STARTUP/gsgen.jar -i logstash.ftl -d $LOGSTASH_ROOT -o $LOGSTASH_ROOT/logstash.conf $VARIABLES



