#!/bin/bash -x

# Set path to keep cron happy
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Create a directory to save the data 
GEOIP_ROOT=/product/logstash/geoip
mkdir --parents --mode=755 ${GEOIP_ROOT}

# Fetch the geo data 
curl -s "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz" -o ${GEOIP_ROOT}/GeoLiteCity.dat.gz
gunzip -f ${GEOIP_ROOT}/GeoLiteCity.dat.gz
