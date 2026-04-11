#!/usr/bin/env bash

# Cache Test Suite to the local Runner cache.

set -eo pipefail

version_file='/cache/test_testsuite/sUMA_4.2.0'
if [[ ! -f $version_file || "${CI_INVALIDATE_CACHES,,}" = "true" ]]
then
     rm -r /cache/test_testsuite || true
     echo "Caching Test Suite files..."
     curl -Lfs -u "${GENERIC_USERNAME}:${GENERIC_PASSWORD}" "${GENERIC_REPOSITORY_URL}/suma/data/sUMA-Test_4.2.0.tar.gz" -o test_testsuite.tar.gz
     tar xvf test_testsuite.tar.gz -C /cache
     touch $version_file
else
     echo "Found Test Suite cache."
fi
