![logo](https://raw.githubusercontent.com/unifiedstreaming/origin/master/unifiedstreaming-logo-black.png)

What is Unified Origin?
-----------------------
Unified Origin offers one solution for just-in-time packaging to MPEG-DASH, Apple (HLS), Adobe (HDS) and Microsoft (MSS). Our added features include content protection, restart TV, time-shift, catchup-TV, subtitles, and multiple language and audio tracks.

Further documentation is available at: <http://docs.unified-streaming.com>

Usage
-----
This image is usable out of the box, but must be configured using environment variables.

Available variables are:

|Variable        |Usage   |Mandatory?|
|----------------|--------|----------|
|USP_LICENSE_KEY |Your license key. To evaluate the software you can create an account at <https://private.unified-streaming.com/register/>|Yes|
|REMOTE_STORAGE_URL|Set an IsmProxyPass to this URL at <http://<container\>/<REMOTE_PATH\>>|No|
|REMOTE_PATH|Set the path to be used for remote storage, defaults to "remote"|No|
|S3_SECRET_KEY|If using S3 remote storage sets the secret key for authentication|No|
|S3_ACCESS_KEY|If using S3 remote storage sets the access key for authentication|No|
|S3_REGION|If using S3 remote storage with v4 authentication set the region|No|
|LOG_LEVEL|Sets the Apache error log level|No|
|LOG_FORMAT|Sets a custom Apache log format|No|


Example
-------
A simple example, running locally on port 1080 with remote storage in S3 and debug logging:

```bash
docker run --rm \
  --name foo \
  -e USP_LICENSE_KEY \
  -e REMOTE_PATH=s3-europe \
  -e REMOTE_STORAGE_URL_A=http://mybucket.s3.eu-west-1.amazonaws.com/ \
  -e S3_ACCESS_KEY_A=<REDACTED> \
  -e S3_SECRET_KEY_A=<REDACTED> \
  -e REMOTE_STORAGE_URL_B=http://mybucket.s3.eu-central-1.amazonaws.com/ \
  -e S3_ACCESS_KEY_B=<REDACTED> \
  -e S3_SECRET_KEY_B=<REDACTED> \
  -e LOG_LEVEL=debug \
  -p 80:80 \
  unifiedstreaming/origin:storagelb
```

Tutorial
--------
A full tutorial is available at <http://docs.unified-streaming.com/installation/evaluation.html>
