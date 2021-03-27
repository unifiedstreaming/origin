![logo](https://raw.githubusercontent.com/unifiedstreaming/origin/master/unifiedstreaming-logo-black.png)

Unified Origin - Storage Proxy (Load-Balanced)
-----------------------------------
The following demo used Unified Origin and Apache's Mod_Proxy_Balancer to offer
the capabilty to load-balancer requests to multiple HTTP based storage locations
(S3 for example). 

This project supports both HTTP, HTTPS, S3-Auth and Manifest-Edit. 

To enable automatic fail-over (incase of failure) Apache's mod_watchdog has been enabled. This uses `hcuri=/tears-of-steel/tears-of-steel.ism` Âto periodically check for the presence of the file. If unavailable, the relevent BalanceMember will be diabled. 

![](flow.png)

Usage
-----
This image is usable out of the box, but must be configured using environment variables.

Available variables are:

|Variable        |Usage   |Mandatory?|
|----------------|--------|----------|
|USP_LICENSE_KEY |Your license key. To evaluate the software you can create an account at <https://private.unified-streaming.com/register/>|Yes|
|REMOTE_STORAGE_URL_A|Set an IsmProxyPass to this URL at <http://<container\>/<REMOTE_PATH\>>|No|
REMOTE_STORAGE_URL_B|Set an IsmProxyPass to this URL at <http://<container\>/<REMOTE_PATH\>>|No|
|REMOTE_PATH|Set the path to be used for remote storage, defaults to "remote"|No|
|S3_SECRET_KEY_A|If using S3 remote storage sets the secret key for authentication|No|
|S3_ACCESS_KEY_B|If using S3 remote storage sets the access key for authentication|No|
|LOG_LEVEL|Sets the Apache error log level|No|
|LOG_FORMAT|Sets a custom Apache log format|No|


Example
-------

Build a container from the DockerFile
```Bash
docker build . -t origin:storagelb 
```
Then run the container locally on port 1080 with remote storage in S3 and debug logging:

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
  -p 1080:80 \
  origin:storagelb
```

Tutorial
--------
A full tutorial is available at <http://docs.unified-streaming.com/installation/evaluation.html>
