#!/bin/bash

# Create a directory to save the data 
GEOIP_ROOT=/project/logstash/geoip
mkdir --parents --mode=755 ${GEOIP_ROOT}

# Fetch the geo data 
curl -s "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz" -o ${GEOIP_ROOT}/GeoLiteCity.dat.gz
gunzip -f ${GEOIP_ROOT}/GeoLiteCity.dat.gz
