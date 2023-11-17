#!/bin/bash
docker run --rm -d \
  -e UspLicenseKey=$UspLicenseKey \
  -e REMOTE_PATH=usp-s3-storage \
  -e REMOTE_STORAGE_URL=http://usp-s3-storage.s3.eu-central-1.amazonaws.com/ \
  -e LOG_LEVEL=info \
  -p 80:80 \
  -v $(pwd)/elephantsdream:/var/www/unified-origin/elephantsdream/ \
  -v $(pwd)/my_use_case.yaml:/etc/manifest-edit/conf/mpd/my_use_case.yaml \
  -v $(pwd)/app:/var/www/unified-origin/wsgi-scripts/ \
  --name origin-modwsgi \
  origin-modwsgi:1.12.11