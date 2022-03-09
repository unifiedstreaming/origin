![logo](https://raw.githubusercontent.com/unifiedstreaming/origin/stable/unifiedstreaming-logo-black.png)

## Manifest Edit "Ops Demo" Image

This Unified Origin image is for Unified internal usage only. Its purpose is to
showcase features under development. It can only be built from Unified local
network, since it makes use of a private development package repository.

### Usage

- Clone this repository and cd into it
- checkout the manifest-edit branch ``git checkout -t origin/manifest-edit``
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
- MPD manifest ``http://localhost/video.ism/.mpd``

then you can apply the use case to the manifest using the URL 

```
http://localhost/video.ism/.mpd?python_pipeline_config=cool-transformation
```

Notice that the query parameter must use the configuration filename only,
**without** the ``.yaml`` extension.

## Excercises

Manifest for DASH exercises: http://localhost/usp-s3-storage/tears-of-steel/tears-of-steel-wvtt.ism/.mpd

Manifest for HLS exercises: http://localhost/usp-s3-storage/tears-of-steel/tears-of-steel-wvtt.ism/.m3u8

### Dash

1. Add an "UTC timing" element.
  Make sure it uses the "urn:mpeg:dash:utc:http-ntp:2014" format and the
  "http://my.timeserver.com/?http-ntp" value.
  Then add a second one using the "urn:mpeg:dash:utc:http-iso:2014" format
  and the "http://my.timeserver.com/?http-iso" value. The resulting manifest
  must have two UTCTiming elements.
2. The manifest has WebVTT subtitles, for which Origin by default
  generates sidecar subtitle tracks.
  Create a Manifest Edit configuration file to remove the sidecar tracks
  (mimeType="text/vtt"): check that the generated manifest is correct.
3. Turn the "English" subtitle track of the manifest into
  "Hard of hearing".
4. Now implement functionalities from both exercise 2 and 3 in a single
   pipeline configuration file.
5. Look at the main playlist of the previous example. The
   ``?python_pipeline_config`` query parameter appears in every media playlist
   URLs. The same happens to DASH Segments URLs. Find a way to avoid this.
6. When generating sidecar subtitle tracks and using the ``--track-description``
   flag, a DASH Label is only added to the fragmented mp4 track and not to the
   sidecar one. Create a pipeline configuration file to add a Label to each
   track with a description of the language (i.e. if lang=en, use and "English"
   Label, for lang=fr use "French" and so on).
7. Change the role of the English subtitle tracks from "subtitle" to
   "forced-subtitle".

### HLS

1. Set the "DEFAULT" subtitle track to "English".


### TIPS

The following workflow is suggested:

- Identify the plugin that seems more relevant to your use case: help yourself
  with the [Plugins Library](http://docs.external.unified-streaming.com/documentation/manifest-edit/plugins_library/index.html)
  or [included Use Cases](http://docs.external.unified-streaming.com/documentation/manifest-edit/use_cases/index.html) documentation pages.
- Identify the example file that seems more relevant to your use case from the
  ``usr/share/manifest-edit`` folder
- copy-paste the content of the example file you have identified into your
  own yaml file in the ``etc/manifest-edit`` folder. Choose a significant name
  for it and use one file per exercise.
- customize the number/order of plugins you need to include in your pipeline,
  if needed.
- for each plugin, customize the yaml lines that select which manifest elements
  are to be edited (see [Element Selection](http://docs.external.unified-streaming.com/documentation/manifest-edit/plugins_library/plugins/mpd/common/manifest_selection.html)
  if needed). Notice that some of the simplest plugins do not require such a
  selection.
- for each plugin, customize the ``plugin_config`` section to configure the
  specific modification you need to apply to the selected element
- troubleshoot using ``docker logs -f``

## Improvements in Manifest Edit installation

The following improvements have been delivered in the dev version of Manifest
Edit and will be present starting from next beta:

- Manifest Edit packages are now a dependency of mod_smooth_streaming on all
  Unix-like OSes. This means that when installing the Origin, all the packages
  and python dependencies that previously had to be installed manually will be
  automatically installed. Also, mod_ext_filter or any other required Apache
  module are loaded by default.
  Notice: this is true for Origin installation, not for Packager! If you just
  install mp4split, you will **not** get Manifest Edit as well but there will
  still be additional packages to install.
  Relevant doc page: http://docs.external.unified-streaming.com/installation/distributions.html#manifest-edit-manifest-edit
- Manifest Edit on Windows has been turned into a "standalone executable"
  using py2exe. The executable and the needed libraries are included in the
  mp4split-1.11.13-win64.zip archive file. The main consequence is that users
  are not required anymore to install Python, pip or any other dependency on
  their system, the zip archive is all that is needed.
  Relevant doc page: http://docs.external.unified-streaming.com/installation/distributions.html#manifest-edit-install-windows
- The Apache default configuration (the one suggested in the doc and the one
  installed by default by Origin installation package) now includes a section
  that activates Manifest Edit. This is not treated anymore as an optional
  step but as something that just should always be there.
  Relevant doc page: http://docs.external.unified-streaming.com/installation/origin/apache.html#sample-apache-configuration-file
- The default configuration goal is to enable the "Just drop a yaml file in a
  folder" approach. This means:
  - installing examples yaml files to ``/usr/share/manifest-edit``
  - having Apache configured to look for them in ``/etc/manifest-edit``, which
    by default is empty
  - activating a use cases just involves creating a yaml files at
    this location (no Apache reconfiguration/restart)
    
  Relevant doc pages:
  - http://docs.external.unified-streaming.com/installation/origin/apache.html#manifest-edit-related-configuration
  - http://docs.external.unified-streaming.com/documentation/manifest-edit/basic_concepts/index.html#integration-with-the-origin
- An updated Apache LocationMatch configuration to enable correct playback
  (i.e. match only manifests URLs, avoid matching media segments) for any
  possible combination of local and remote storage.
  Relevant doc page: http://docs.external.unified-streaming.com/installation/origin/apache.html#apache-configuration-walkthrough

Included in this image but subject to review:

- a modified version of ``mod_ext_filter``, called ``mod_unified_filter``,
  allowing 500 Status in case of non-existing/incorrect yaml files.
  This will be removed and most probably we will revert to the old behaviour
  of getting a 200 Status with an empty body in case of error.

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