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
docker run \
  -e USP_LICENSE_KEY=<license_key> \
  -e REMOTE_STORAGE_URL=http://usp-s3-storage.s3.eu-central-1.amazonaws.com/ \
  -e LOG_LEVEL=debug \
  -p 1080:80 \
  unifiedstreaming/origin:1.10.28
```

Tutorial
--------
A full tutorial is available at <http://docs.unified-streaming.com/installation/evaluation.html>

Manifest Edit functionality and default pipelines
---------------------------------------------------

This Origin image includes the "Manifest Edit" functionality, allowing you to
test the use cases included "out-of-the-box" in our Plugins Library, which
are documented in the Use Cases doc page 
<https://docs.unified-streaming.com/documentation/manifest-edit/use_cases/index.html>.

You can enable each use case by adding to any `/.mpd` url a query parameter
passing a pipeline name, which will generate an "edited" manifest.
The available pipelines are:

- `?pipeline=adaptation_sets_order`
- `?pipeline=adaptation_sets_removal`
- `?pipeline=adaptation_sets_representations_order`
- `?pipeline=adaptation_sets_switching`
- `?pipeline=low_latency`
- `?pipeline=low_latency_with_essential_property`
- `?pipeline=representations_order`
- `?pipeline=representations_removal`
- `?pipeline=supplemental_property_add`
- `?pipeline=utc_add`
- `?pipeline=utc_change`
- `?pipeline=utc_remove`

These pre-configured use cases may or may not apply at all to your content.

Manifest Edit customized pipeline
---------------------------------

If you want to experiment creating your own pipeline, the suggested way to
do so is to mount in the docker image the provided `my_use_case.yaml` file
using the additional docker run options

```bash
docker run \
  <...> \
  -v "$(pwd)"/my_use_case.yaml:/usr/share/manifest-edit/my_use_case.yaml \
  -e MY_USE_CASE=my_use_case \
  <...>
```
You can now edit the `my_use_case.yaml` local file based on your needs. Refer
to individual plugins documentation for instructions on how to do so. Any
saved change will be immediately available: the corresponding pipeline can be
invoked with the query parameter

- `?pipeline=my_use_case`