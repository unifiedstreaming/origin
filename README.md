![logo](https://raw.githubusercontent.com/unifiedstreaming/origin/stable/unifiedstreaming-logo-black.png)

# What is Unified Origin?

Unified Origin offers one solution for just-in-time packaging to MPEG-DASH, Apple (HLS), Adobe (HDS) and Microsoft (MSS). Our added features include content protection, restart TV, time-shift, catchup-TV, subtitles, and multiple language and audio tracks.

Further documentation is available at: <http://docs.unified-streaming.com>

## Usage

Note: for running in production we strongly recommend either [building your own
Docker image](https://docs.unified-streaming.com/installation/evaluation.html#creating-your-own-docker-images),
or using this image with additional configuration files in order to set up access control, tune Apache MPM, etc.

This image is usable out of the box, but must be configured using environment variables.

Available variables are:

|Variable        |Usage   |Mandatory?|
|----------------|--------|----------|
|UspLicenseKey |Your license key. To evaluate the software you can create an account at <https://private.unified-streaming.com/register/>|Yes|
|REMOTE_STORAGE_URL|Set an IsmProxyPass to this URL at <http://<container\>/<REMOTE_PATH\>>|No|
|REMOTE_PATH|Set the path to be used for remote storage, defaults to "remote"|No|
|S3_SECRET_KEY|If using S3 remote storage sets the secret key for authentication|No|
|S3_ACCESS_KEY|If using S3 remote storage sets the access key for authentication|No|
|S3_REGION|If using S3 remote storage with v4 authentication set the region|No|
|LOG_LEVEL|Sets the Apache error log level|No|
|LOG_FORMAT|Sets a custom Apache log format|No|
|REST_API_PORT|Enable the REST API for publishing point management on this port|No|

### Apache Configuration
Additional Apache configuration files can be used by mounting them as Docker
volumes, for example:

```bash
docker run \
  -e UspLicenseKey=<license_key> \
  -v foo.conf:/etc/apache2/conf.d/foo.conf \
  -p 80:80 \
  unifiedstreaming/origin:latest
```

## Tutorial

A full tutorial is available at <http://docs.unified-streaming.com/installation/evaluation.html>

## Manifest Edit

This image also contains Manifest Edit functionality with a set of default
use cases as described in our [documentation](https://docs.unified-streaming.com/documentation/manifest-edit/use_cases/index.html).

A default yaml configuration file is directly accessible, per each available
manifest format, in the `/etc/manifest-edit/conf/mpd`, 
`/etc/manifest-edit/conf/m3u8_main`, `/etc/manifest-edit/conf/m3u8_media`
folder. You can enable various use cases by just uncommenting specific sections
in these yaml files and then adding to any `/.mpd` or `/.m3u8` url a query
parameter `?python_pipeline_config=mpd/default`,
`?python_pipeline_config=m3u8_main/default`, or
`?python_pipeline_config=m3u8_media/default`.

Alternatively, you can create your own configuration file. The recommended way
is to start from existing example configuration files present in the
`/usr/share/manifest-edit` folder. Copy the
one you want to activate in the `/etc/manifest-edit/conf` folder and edit
based on your need. You can now activate the use case by adding to
any `/.mpd` or `/.m3u8` url a query parameter passing the pipeline name, which
will generate an "edited" manifest.

For example, after creating an `/etc/manifest-edit/conf/mpd/my_use_case.yaml`,
you can activate it with the URL query parameter

- `?python_pipeline_config=mpd/my_use_case`

Notice that example yaml files use some defaults that may or may not
apply at all to your content (i.e. a pipeline may be configured to edit a
subtitle track, but the original manifest may not have one)! If, after invoking
a pipeline, you don't see any evident change in the manifest, check the
pipeline configuration, reported in a comment header in the manifest itself and
see if any change in the manifest is indeed expected or for that particular
manifest.
This may happen for HLS manifests as well, i.e. the `default_audio_language` 
pipeline sets English as the default audio track. If
that is already the default track in your original manifest, you will notice
no visible changes in the edited manifest.

