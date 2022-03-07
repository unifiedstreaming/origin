#!/bin/bash
LOCAL_MANIFEST_EDIT_EXAMPLES=usr/share/manifest-edit

docker run --rm -d \
  -e UspLicenseKey=$UspLicenseKey \
  -e REMOTE_PATH=usp-s3-storage \
  -e REMOTE_STORAGE_URL=http://usp-s3-storage.s3.eu-central-1.amazonaws.com/ \
  -e LOCAL_MANIFEST_EDIT_EXAMPLES=${LOCAL_MANIFEST_EDIT_EXAMPLES} \
  -v $(pwd)/${LOCAL_MANIFEST_EDIT_EXAMPLES}:/host/${LOCAL_MANIFEST_EDIT_EXAMPLES}/ \
  -v $(pwd)/etc/manifest-edit:/etc/manifest-edit/ \
  -p 80:80 \
  --name manifest_edit \
  unifiedstreaming/origin:25881-dev

# optionally mount local folder with content in container folder
# -v $(pwd)/tos:/var/www/unified-origin/tos/ \