#!/bin/sh
set -e

# Validate license key variable is set
if [ -z "$UspLicenseKey" ] && [ -z "$USP_LICENSE_KEY" ]
  then
  echo >&2 "Error: UspLicenseKey environment variable is required but not set."
  exit 1
elif [ -z "$UspLicenseKey" ]
  then
  export UspLicenseKey=$USP_LICENSE_KEY
fi

# write license key to file
echo "$UspLicenseKey" > /etc/usp-license.key

# If specified, override default log level and format config
if [ "$LOG_FORMAT" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D LOG_FORMAT"
fi
if [ "$LOG_LEVEL" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D LOG_LEVEL"
fi

# Remote storage URL and storage proxy config
if [ "$REMOTE_STORAGE_URL" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D REMOTE_STORAGE_URL"
  if [ -z "$REMOTE_PATH" ]
  then
    export REMOTE_PATH=remote
  fi
fi
if [ "$S3_ACCESS_KEY" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_ACCESS_KEY"
fi
if [ "$S3_SECRET_KEY" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_SECRET_KEY"
fi
if [ "$S3_SECURITY_TOKEN" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_SECURITY_TOKEN"
fi
if [ "$S3_REGION" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_REGION"
fi

# REST API
if [ "$REST_API_PORT" ]
  then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D REST_API_PORT"
fi


# First arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- apachectl $EXTRA_OPTIONS "$@"
fi

uwsgi --socket localhost:3002 \
  --plugins python3 \
  --protocol uwsgi \
  --wsgi-file /var/www/unified-origin/wsgi-scripts/manifestedit.wsgi &

exec "$@"