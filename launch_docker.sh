#!/bin/bash
docker run --rm -d \
  -e UspLicenseKey=$UspLicenseKey \
  -e REMOTE_PATH=usp-s3-storage \
  -e REMOTE_STORAGE_URL=http://usp-s3-storage.s3.eu-central-1.amazonaws.com/ \
  -e LOG_LEVEL=trace4 \
  -p 80:80 \
  -v $(pwd)/manifests:/root/manifests \
  --name origin \
  origin:1.12.1

#-v $(pwd)/elephantsdream:/var/www/unified-origin/elephantsdream/ \