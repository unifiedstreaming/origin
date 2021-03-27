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
if [ -z "$USP_LICENSE_KEY" ]
  then
  echo >&2 "Error: USP_LICENSE_KEY environment variable is required but not set."
  exit 1
fi

# set remote path
if [ $REMOTE_PATH ]
  then
  /bin/sed "s@{{LOG_LEVEL}}@${LOG_LEVEL}@g; s@{{LOG_FORMAT}}@'${LOG_FORMAT}'@g; s@{{REMOTE_PATH}}@${REMOTE_PATH}@g" /etc/apache2/conf.d/unified-origin.conf.in > /etc/apache2/conf.d/unified-origin.conf
fi

# remote storage
# To remove preview and set at url
# sed -E 's_^(https|http)?://__'
if [ $REMOTE_STORAGE_URL_A -a $REMOTE_STORAGE_URL_B ]
  then
  REMOTE_STORAGE_LOCATION_A=$(echo $REMOTE_STORAGE_URL_A | sed -E 's_^(https|http)?://__');
  REMOTE_STORAGE_LOCATION_B=$(echo $REMOTE_STORAGE_URL_B | sed -E 's_^(https|http)?://__');
  /bin/sed "s@{{LOG_LEVEL}}@${LOG_LEVEL}@g; s@{{LOG_FORMAT}}@'${LOG_FORMAT}'@g; s@{{REMOTE_PATH}}@${REMOTE_PATH}@g" /etc/apache2/conf.d/unified-origin.conf.in > /etc/apache2/conf.d/unified-origin.conf;
  /bin/sed "s@{{LOG_LEVEL}}@${LOG_LEVEL}@g; s@{{LOG_FORMAT}}@'${LOG_FORMAT}'@g; s@{{REMOTE_STORAGE_URL_A}}@${REMOTE_STORAGE_URL_A}@g; s@{{REMOTE_STORAGE_URL_B}}@${REMOTE_STORAGE_URL_B}@g; s@{{REMOTE_STORAGE_LOCATION_A}}@${REMOTE_STORAGE_LOCATION_A}@g; s@{{REMOTE_STORAGE_LOCATION_B}}@${REMOTE_STORAGE_LOCATION_B}@g" /etc/apache2/conf.d/remote_storage.conf.in > /etc/apache2/conf.d/remote_storage.conf
  else
  echo >&2 "Please set url's for both REMOTE_STORAGE_URL_A anf REMOTE_STORAGE_URL_B"
  exit 1
fi


# s3 auth
if [ $S3_ACCESS_KEY_A  -a $S3_SECRET_KEY_A -a $S3_ACCESS_KEY_B  -a $S3_SECRET_KEY_B ]
  then
  S3_REGION_A=$(echo $REMOTE_STORAGE_URL_A | awk -F "." '{print $3}');
  S3_REGION_B=$(echo $REMOTE_STORAGE_URL_B | awk -F "." '{print $3}');
  /bin/sed "s@{{REMOTE_STORAGE_URL_A}}@${REMOTE_STORAGE_URL_A}@g; s@{{REMOTE_STORAGE_URL_B}}@${REMOTE_STORAGE_URL_B}@g; s@{{S3_ACCESS_KEY_A}}@${S3_ACCESS_KEY_A}@g; s@{{S3_SECRET_KEY_A}}@${S3_SECRET_KEY_A}@g; s@{{S3_REGION_A}}@${S3_REGION_A}@g; s@{{S3_ACCESS_KEY_B}}@${S3_ACCESS_KEY_B}@g; s@{{S3_SECRET_KEY_B}}@${S3_SECRET_KEY_B}@g; s@{{S3_REGION_B}}@${S3_REGION_B}@g;" /etc/apache2/conf.d/s3_auth.conf.in > /etc/apache2/conf.d/s3_auth.conf
  else 
  echo >&2 "Please set ACCESS_KEY & SECRET_KEY for both REMOTE_STORAGE's "
  exit 1
fi


# transcode
if [ $TRANSCODE_PATH ] && [ $TRANSCODE_URL ]
  then
  /bin/sed "s@{{TRANSCODE_PATH}}@${TRANSCODE_PATH}@g; s@{{TRANSCODE_URL}}@${TRANSCODE_URL}@g; s@{{REMOTE_STORAGE_URL}}@${REMOTE_STORAGE_URL}@g" /etc/apache2/conf.d/transcode.conf.in > /etc/apache2/conf.d/transcode.conf
fi


# USP license
echo $USP_LICENSE_KEY > /etc/usp-license.key

rm -f /run/apache2/httpd.pid

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- httpd "$@"
fi

exec "$@"
