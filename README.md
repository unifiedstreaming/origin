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
|UspLicenseKey |Your license key. To evaluate the software you can create an account at <https://private.unified-streaming.com/register/>|Yes|
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
  -e UspLicenseKey=<license_key> \
  -e REMOTE_PATH=usp-s3-storage \
  -e REMOTE_STORAGE_URL=http://usp-s3-storage.s3.eu-central-1.amazonaws.com/ \
  -e LOG_LEVEL=debug \
  -p 1080:80 \
  unifiedstreaming/origin
```

Then request a client manifest via:
```bash
curl -s http://localhost:1080/usp-s3-storage/tears-of-steel/tears-of-steel-avc1.ism/.m3u8

#EXTM3U
#EXT-X-VERSION:4
## Created with Unified Streaming Platform  (version=1.11.1-24062)

# AUDIO groups
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-aacl-64",LANGUAGE="en",NAME="English",DEFAULT=YES,AUTOSELECT=YES,CHANNELS="2"
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-aacl-128",LANGUAGE="en",NAME="English",DEFAULT=YES,AUTOSELECT=YES,CHANNELS="2"

# SUBTITLES groups
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="textstream",LANGUAGE="en",NAME="English",DEFAULT=YES,AUTOSELECT=YES,URI="tears-of-steel-avc1-textstream_eng=1000.m3u8"
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="textstream",LANGUAGE="zh-Hans",NAME="Chinese (zh-Hans)",AUTOSELECT=YES,URI="tears-of-steel-avc1-textstream_zh-Hans=1000.m3u8"

# variants
#EXT-X-STREAM-INF:BANDWIDTH=494000,CODECS="mp4a.40.2,avc1.42C00D",RESOLUTION=224x100,FRAME-RATE=24,AUDIO="audio-aacl-64",SUBTITLES="textstream",CLOSED-CAPTIONS=NONE
tears-of-steel-avc1-audio_eng=64008-video_eng=401000.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=933000,CODECS="mp4a.40.2,avc1.42C016",RESOLUTION=448x200,FRAME-RATE=24,AUDIO="audio-aacl-128",SUBTITLES="textstream",CLOSED-CAPTIONS=NONE
tears-of-steel-avc1-audio_eng=128002-video_eng=751000.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1198000,CODECS="mp4a.40.2,avc1.4D401F",RESOLUTION=784x350,FRAME-RATE=24,AUDIO="audio-aacl-128",SUBTITLES="textstream",CLOSED-CAPTIONS=NONE
tears-of-steel-avc1-audio_eng=128002-video_eng=1001000.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1728000,CODECS="mp4a.40.2,avc1.640028",RESOLUTION=1680x750,FRAME-RATE=24,VIDEO-RANGE=SDR,AUDIO="audio-aacl-128",SUBTITLES="textstream",CLOSED-CAPTIONS=NONE
tears-of-steel-avc1-audio_eng=128002-video_eng=1501000.m3u8

# variants
#EXT-X-STREAM-INF:BANDWIDTH=69000,CODECS="mp4a.40.2",AUDIO="audio-aacl-64",SUBTITLES="textstream"
tears-of-steel-avc1-audio_eng=64008.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=137000,CODECS="mp4a.40.2",AUDIO="audio-aacl-128",SUBTITLES="textstream"
tears-of-steel-avc1-audio_eng=128002.m3u8

# keyframes
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=54000,CODECS="avc1.42C00D",RESOLUTION=224x100,URI="keyframes/tears-of-steel-avc1-video_eng=401000.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=100000,CODECS="avc1.42C016",RESOLUTION=448x200,URI="keyframes/tears-of-steel-avc1-video_eng=751000.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=133000,CODECS="avc1.4D401F",RESOLUTION=784x350,URI="keyframes/tears-of-steel-avc1-video_eng=1001000.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=199000,CODECS="avc1.640028",RESOLUTION=1680x750,VIDEO-RANGE=SDR,URI="keyframes/tears-of-steel-avc1-video_eng=1501000.m3u8"
```

Tutorial
--------
A full tutorial is available at <http://docs.unified-streaming.com/installation/evaluation.html>
