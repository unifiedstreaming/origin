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

> **NOTICE**: older versions of this Docker image (prior to 1.11.13) used a different setup for accessing the default Manifest Edit pipelines, they now need to be referred to including the manifest type in the path.

This image also contains Manifest Edit functionality with a set of default
use cases as described in our [documentation](https://docs.unified-streaming.com/documentation/manifest-edit/use_cases/index.html).

You can enable each use case by adding to any `/.mpd` or `/.m3u8` url a query
parameter passing a pipeline name, which will generate an "edited" manifest.
The available pipelines for `/.mpd` urls are:

- `?python_pipeline_config=mpd/accessibility_add`
- `?python_pipeline_config=mpd/adaptation_sets_order`
- `?python_pipeline_config=mpd/adaptation_sets_removal`
- `?python_pipeline_config=mpd/adaptation_sets_representations_order`
- `?python_pipeline_config=mpd/adaptation_sets_switching`
- `?python_pipeline_config=mpd/audiochannelconfiguration_add`
- `?python_pipeline_config=mpd/essential_property_add`
- `?python_pipeline_config=mpd/essential_property_remove`
- `?python_pipeline_config=mpd/eventstream_value_add`
- `?python_pipeline_config=mpd/hard_of_hearing_add`
- `?python_pipeline_config=mpd/label_add`
- `?python_pipeline_config=mpd/label_remove`
- `?python_pipeline_config=mpd/low_latency`
- `?python_pipeline_config=mpd/low_latency_with_essential_property`
- `?python_pipeline_config=mpd/multiple_isms.yaml`
- `?python_pipeline_config=mpd/representations_order`
- `?python_pipeline_config=mpd/representations_remove`
- `?python_pipeline_config=mpd/role_add`
- `?python_pipeline_config=mpd/supplemental_property_add`
- `?python_pipeline_config=mpd/supplemental_property_remove`
- `?python_pipeline_config=mpd/utc_add`
- `?python_pipeline_config=mpd/utc_change`
- `?python_pipeline_config=mpd/utc_remove`

The available pipelines for `/.m3u8` urls are:

- `?python_pipeline_config=m3u8/default_audio_language`
- `?python_pipeline_config=m3u8/default_subs_language`
- `?python_pipeline_config=m3u8/hard_of_hearing`

These pre-configured use cases are using some defaults that may or may not
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

In these cases, either edit the pipeline
configuration file in the `/usr/share/manifest-edit` folder of the
docker image, or read next chapter to create and use your own custom
configuration file.

### Manifest Edit customized pipeline

If you want to experiment creating your own pipeline, the suggested way to
do so is to edit the provided `my_use_case.yaml` file and mount in the docker
image using additional docker run options (see the following example):

```bash
docker run \
  -e UspLicenseKey=<license_key> \
  -e REMOTE_PATH=usp-s3-storage \
  -e REMOTE_STORAGE_URL=http://usp-s3-storage.s3.eu-central-1.amazonaws.com/ \
  -v "$(pwd)"/my_use_case.yaml:/etc/manifest-edit/my_use_case.yaml \
  -p 1080:80 \
  --name unified-origin-manifest-edit \
  unifiedstreaming/origin:latest
```

You can now edit the `my_use_case.yaml` local file based on your needs. Refer
to individual plugins documentation for instructions on how to do so. Any
saved change will be immediately available: the corresponding pipeline can be
invoked with the query parameter

- `?python_pipeline_config=my_use_case`
