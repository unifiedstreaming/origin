#!/bin/sh
set -e

# set env vars to defaults if not already set
if [ -z "$LOG_LEVEL" ]
  then
  export LOG_LEVEL=warn
fi

if [ -z "$LOG_FORMAT" ]
  then
  export LOG_FORMAT="%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" %D"
fi

if [ -z "$REMOTE_PATH" ]
  then
  export REMOTE_PATH=remote
fi

# validate required variables are set
if [ -z "$UspLicenseKey" ] && [ -z "$USP_LICENSE_KEY" ]
  then
  echo >&2 "Error: UspLicenseKey environment variable is required but not set."
  exit 1
elif [ -z "$UspLicenseKey" ]
  then
  export UspLicenseKey=$USP_LICENSE_KEY
fi

# set up remote storage proxy config
if [ "$S3_ACCESS_KEY" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_ACCESS_KEY"
fi
if [ "$S3_SECRET_KEY" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_SECRET_KEY"
fi
if [ "$S3_REGION" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_REGION"
fi

# remote storage
if [ "$REMOTE_STORAGE_URL" ]
  then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D REMOTE_STORAGE_URL"
fi

# REST API
if [ "$REST_API_PORT" ]
  then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D REST_API_PORT"
fi

# change Listen 80 to Listen 0.0.0.0:80 to avoid some strange issues when IPv6 is available
/bin/sed -i "s@Listen 80@Listen 0.0.0.0:80@g" /etc/apache2/httpd.conf

# USP license
echo "$UspLicenseKey" > /etc/usp-license.key

rm -f /run/apache2/httpd.pid

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- httpd $EXTRA_OPTIONS "$@"
fi

exec "$@"