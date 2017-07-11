#!/bin/bash

set -e

if [[ -z "${DB_SSL_KEY_PATH}" ]]; then
  echo 'no ssl key path' > /dev/null
else
  chmod 600 $DB_SSL_KEY_PATH
fi
