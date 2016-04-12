#!/bin/bash -x

source /tmp/context

# Assume the following environment variables are passed in
# ES = Elasticsearch end point
#
# Optionally control how many days of past indices are maintained
# INDEX_AGE

# Set path to keep cron happy
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Do nothing if required age unknown - allows function to be turned off
if [[ "${ES}" == "" || "${INDEX_AGE}" == "" ]]; then 
	echo "No index age specified. Nothing to do."
	exit 0
fi

# Cycle through the current indexes
for INDEX in $(curl -s "${ES}/_cat/indices?h=i" | grep "logs-" | sort); do
    INDEX_DATE=$(echo ${INDEX} | cut -f2 -d"-" | tr "." "-")
    AGE=$(( ($(date -u +%s) - $(date -ud ${INDEX_DATE} +%s))/24/3600  ))
    if [[ $? -eq 0 ]]; then
        echo "${INDEX} is ${AGE} days old"
        if [[ ${AGE} -gt ${INDEX_AGE} ]]; then
            echo "Deleting ${INDEX} ..."
            curl -XDELETE "${ES}/${INDEX}"
        fi
    fi
done

exit 0

