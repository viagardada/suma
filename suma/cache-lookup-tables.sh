#!/usr/bin/env bash

# Cache lookup tables to the local Runner cache.

set -eo pipefail

version_file='/cache/LookupTables/sUMA_4.2.0'
if [[ ! -f $version_file || "${CI_INVALIDATE_CACHES,,}" = "true" ]]
then
     rm -r /cache/LookupTables || true
     echo "Caching Lookup Tables..."
     curl -Lfs -u "${GENERIC_USERNAME}:${GENERIC_PASSWORD}" "${GENERIC_REPOSITORY_URL}/suma/data/sUMA_4.2.0.tar.gz" -o LookupTables.tar.gz
     tar xvf LookupTables.tar.gz -C /cache/
     touch $version_file
else
     echo "Found Lookup Table cache."
fi
