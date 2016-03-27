#!/bin/bash

# Assume the following environment variable passed in
# LOGS = logs bucket name
# REGION = logs bucket region
#
# Optionally control how many days of past logs are loaded initially
# CACHE_AGE

# Create a directory to save the data 
CACHE_ROOT="/project/logstash/cache/awslogs"
mkdir --parents --mode=777 $CACHE_ROOT

# How many days of history do we want including today
if [[ "$CACHE_AGE" == "" ]]; then 
	CACHE_AGE="5"
fi

# Assume the following passed in
# LOGS = logs bucket
# REGION = logs bucket region
ACCOUNT=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep accountId | cut -d \" -f 4)

# Sync today's logs
for i in $(seq 0 $[${CACHE_AGE}-1]); do 
  DATE=$(date --utc +%Y/%m/%d -d "$i days ago")
  aws --region ${REGION} s3 sync s3://${LOGS}/AWSLogs/${ACCOUNT}/elasticloadbalancing/${REGION}/${DATE}/ ${CACHE_ROOT}/elasticloadbalancing/${DATE}/
done

# Purge any older than a week
find ${CACHE_ROOT} -mtime +${CACHE_AGE} -exec rm {} \;

