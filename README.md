![logo](https://raw.githubusercontent.com/unifiedstreaming/origin/stable/unifiedstreaming-logo-black.png)

## Manifest Edit "Ops Demo" Image

This Unified Origin image is for Unified internal usage only. Its purpose is to
showcase features under development. It can only be built from Unified local
network, since it makes use of a private development package repository.

### Usage

- Clone this repository and cd into it
- build the image ``docker build -t unifiedstreaming/origin:25881-dev docker/origin``
- on the bash terminal you are going to use, export your license
  ``export UspLicenseKey=<your license>``
- launch an Origin container using the included ``launch_docker.sh`` script

The Origin is pre-configured with Manifest Edit functionalities activated.
Use cases are enabled by pipeline configuration files which the Origin reads
from the ``/etc/manifest-edit`` folder. By default, this folder is empty.
Users are expected to populate it with one pipeline configuration file per use
case that they wish to activate. 

Notice that when using this container you can add your configuration files to
the locally-mounted ``etc/manifest-edit`` subfolder of this working copy.

A copy of the example pipeline configuration files shipped with the
Origin installation is available in the local folder
``usr/share/manifest-edit`` (populated at container startup). Consider these
YAMLs a read-only copy to use as a reference when creating your own. Do not
edit these files.

Once you have a yaml configuration file in ``etc/manifest-edit``, you
can apply the related use case to a manifest by just appending the query
parameter string ``?python_pipeline_config=<yaml file name>`` to the manifest
URL. I.e. suppose your pipeline file and manifest are:

- pipeline file ``etc/manifest-edit/cool-transformation.yaml``
- MPD manifest ``http://localhost/video.ism/.mpd``,

then you can apply the use case to the manifest using the URL 

```
http://localhost/video.ism/.mpd?python_pipeline_config=cool-transformation
```

Notice that the query parameter must use the configuration filename only,
**without** the ``.yaml`` extension.

## Excercises

1. Add an "UTC timing" element to the following manifest: http://localhost/usp-s3-storage/tears-of-steel/tears-of-steel-wvtt.ism/.mpd.
  Make sure it uses the "urn:mpeg:dash:utc:http-ntp:2014" format and the
  "http://my.timeserver.com/?http-ntp" value.
  Then add a second one using the "urn:mpeg:dash:utc:http-iso:2014" format
  and the "http://my.timeserver.com/?http-iso" value. The resulting manifest
  must have two UTCTiming elements.
2. The following manifest has WebVTT subtitles, for which Origin by default
  generates sidecar subtitle tracks: http://localhost/usp-s3-storage/tears-of-steel/tears-of-steel-wvtt.ism/.mpd
  Create a Manifest Edit configuration file to remove the sidecar tracks
  (mimeType="text/vtt"): check that the generated manifest is correct.
3. Turn the "English" subtitle track of the following manifest into
  "Hard of hearing": http://localhost/usp-s3-storage/tears-of-steel/tears-of-steel-wvtt.ism/.mpd
4. Set the "DEFAULT" subtitle track to "English" in the following main
   playlist: http://localhost/usp-s3-storage/tears-of-steel/tears-of-steel-wvtt.ism/.m3u8
5. Look at the main playlist of the previous example. The
   ``?python_pipeline_config`` query parameter appears in every media playlist
   URLs. Find a way to avoid this.


### TIPS

The following workflow is suggested:

- Identify the plugin that seems more relevant to your use case: help yourself
  with the [Plugins Library](http://docs.external.unified-streaming.com/documentation/manifest-edit/plugins_library/index.html)
  or [included Use Cases](http://docs.external.unified-streaming.com/documentation/manifest-edit/use_cases/index.html) documentation pages.
- Identify the example file that seems more relevant to your use case from the
  ``usr/share/manifest-edit`` folder
- copy-paste the content of the example file you have identified into your
  own yaml file in the ``etc/manifest-edit`` folder. Choose a significant name
  for it.
- customize the number/order of plugins you need to include in your pipeline,
  if needed.
- for each plugin, customize the yaml lines that select which manifest elements
  are to be edited (see [Element Selection](http://docs.external.unified-streaming.com/documentation/manifest-edit/plugins_library/plugins/mpd/common/manifest_selection.html)
  if needed). Notice that some of the simplest plugins do not require such a
  selection.
- for each plugin, customize the ``plugin_config`` section to configure the
  specific modification you need to apply to the selected element
- troubleshoot using ``docker logs -f``

## General reminder about Origin image usage

This image is not different at all from a plain Origin image in terms of
installation and configuration. Nothing has been modified in that regard to
provide manifest-edit specific configuration.

The only changes specific to this demo have been done to the Dockerfile and
entrypoint.sh script, just to make the default manifest edit example files
available in a host folder, to simplify access to them instead than just
leaving them in the container.

The provided launcher script as well just deals with enabling the right
mount and enabling remote storage.

This image is usable out of the box, but must be configured using environment
variables. 

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
  unifiedstreaming/unified-origin:latest
```