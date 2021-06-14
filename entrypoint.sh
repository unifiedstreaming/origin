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
if [ -z "$UspLicenseKey" ]
  then
  echo >&2 "Error: USP_LICENSE_KEY environment variable is required but not set."
  exit 1
fi

# update configuration based on env vars
# log levels
/bin/sed "s@{{LOG_LEVEL}}@${LOG_LEVEL}@g; s@{{LOG_FORMAT}}@'${LOG_FORMAT}'@g;" /etc/apache2/conf.d/unified-origin.conf.in > /etc/apache2/conf.d/unified-origin.conf

# remote storage
if [ $REMOTE_STORAGE_URL ]
  then
  /bin/sed "s@{{REMOTE_PATH}}@${REMOTE_PATH}@g; s@{{REMOTE_STORAGE_URL}}@${REMOTE_STORAGE_URL}@g" /etc/apache2/conf.d/remote_storage.conf.in > /etc/apache2/conf.d/remote_storage.conf
fi

# s3 auth
if [ $S3_ACCESS_KEY ] && [ $S3_SECRET_KEY ] && [ $S3_REGION ]
  then
  S3_REGION="S3Region ${S3_REGION}"
  /bin/sed "s@{{REMOTE_STORAGE_URL}}@${REMOTE_STORAGE_URL}@g; s@{{REMOTE_PATH}}@${REMOTE_PATH}@g; s@{{S3_ACCESS_KEY}}@${S3_ACCESS_KEY}@g; s@{{S3_SECRET_KEY}}@${S3_SECRET_KEY}@g; s@{{S3_REGION}}@${S3_REGION}@g" /etc/apache2/conf.d/s3_auth.conf.in > /etc/apache2/conf.d/s3_auth.conf
fi
if [ $S3_ACCESS_KEY ] && [ $S3_SECRET_KEY ] && [ -z $S3_REGION ]
  then
  /bin/sed "s@{{REMOTE_STORAGE_URL}}@${REMOTE_STORAGE_URL}@g; s@{{REMOTE_PATH}}@${REMOTE_PATH}@g; s@{{S3_ACCESS_KEY}}@${S3_ACCESS_KEY}@g; s@{{S3_SECRET_KEY}}@${S3_SECRET_KEY}@g; s@{{S3_REGION}}@@g" /etc/apache2/conf.d/s3_auth.conf.in > /etc/apache2/conf.d/s3_auth.conf
fi

# transcode
if [ $TRANSCODE_PATH ] && [ $TRANSCODE_URL ]
  then
  /bin/sed "s@{{TRANSCODE_PATH}}@${TRANSCODE_PATH}@g; s@{{TRANSCODE_URL}}@${TRANSCODE_URL}@g; s@{{REMOTE_STORAGE_URL}}@${REMOTE_STORAGE_URL}@g" /etc/apache2/conf.d/transcode.conf.in > /etc/apache2/conf.d/transcode.conf
fi


# USP license
echo $UspLicenseKey > /etc/usp-license.key

rm -f /run/apache2/httpd.pid

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- httpd "$@"
fi

exec "$@"
