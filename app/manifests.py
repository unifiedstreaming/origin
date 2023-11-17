import base64
import logging
from enum import Enum

import manifest_edit.libfmp4 as libfmp4

logger = logging.getLogger(__name__)


class Format(str, Enum):
    MPD = "mpd"
    M3U8_MAIN = "m3u8_main"
    M3U8_MEDIA = "m3u8_media"


def to_bytes(manifest) -> bytes:
    return str(manifest).encode("utf-8")


def _is_mpd(payload: bytes) -> bool:
    if b"<?xml" in payload[:100]:
        return True
    else:
        return False


def _is_master_playlist(payload: bytes) -> bool:
    """
    There are two types of m3u8 manifests:

    - the "Multivariant" one (i.e. https://developer.apple.com/documentation/
      http_live_streaming/example_playlists_for_http_live_streaming/
      creating_a_multivariant_playlist). This is represented correctly by the
      libfmp4.hsl.Manifest type
    - the "Media" one (i.e. https://developer.apple.com/documentation/
      http_live_streaming/example_playlists_for_http_live_streaming/
      video_on_demand_playlist_construction). This is represented correctly by the
      libfmp4.hls.Playlist type

    This function will determine which manifest to parse to by applying the same logic
    seen in the m3u8_reader.cpp::is_master_playlist function, that is

    - read manifest line by line
    - if line starts with '#EXT-X-MEDIA-SEQUENCE:' it's a Playlist (Media)
    - if line starts with '#EXT-X-STREAM-INF:' it's a Manifest (Master/Multivariant)
    - if none of the above are found, defaults to Playlist (Media)
    """
    for line in payload.split(b"\n"):
        if line.startswith(b"#EXT-X-MEDIA-SEQUENCE:"):
            return False
        elif line.startswith(b"#EXT-X-STREAM-INF:"):
            return True

    return False


def _get_manifest_format(payload: bytes) -> Format:
    """
    Determines manifest format. Can be:

    - MPD
    - M3U8_MAIN
    - M3U8_MEDIA
    """
    if _is_mpd(payload):
        return Format.MPD
    elif _is_master_playlist(payload):
        return Format.M3U8_MAIN
    else:
        return Format.M3U8_MEDIA


def _bytes_to_data_url(payload: bytes) -> str:
    """
    Takes bytes and returns a plain text base64 data url. Only way to ship a buffer
    to libfmp4.

    At some point, we'll need to understand what kind of manifest this byte string
    represents. This is probably the right moment to parse the byte string, before
    turning it into a base64 encoded representation.
    """

    return (
        f"data:text/plain;base64,{base64.b64encode(payload).decode(encoding='ascii')}"
    )


def from_bytes(payload: bytes):

    data_url = _bytes_to_data_url(payload)
    format = _get_manifest_format(payload)

    if format == Format.MPD:
        return dash_get(url=data_url)
    elif format == Format.M3U8_MAIN:
        return hls_manifest_get(url=data_url)
    elif format == Format.M3U8_MEDIA:
        return hls_playlist_get(url=data_url)

def dash_get(url: str) -> libfmp4.mpd.Manifest:
    context = libfmp4.Context()
    return libfmp4.mpd.load_manifest(context, url)


def hls_manifest_get(url: str) -> libfmp4.hls.Manifest:
    context = libfmp4.Context()
    return libfmp4.hls.load_master_playlist(context, url)


def hls_playlist_get(url: str) -> libfmp4.hls.Playlist:
    context = libfmp4.Context()
    return libfmp4.hls.load_media_playlist(context, url)


def get_format(manifest) -> Format:
    if type(manifest) == libfmp4.hls.Manifest:
        return Format.M3U8_MAIN
    elif type(manifest) == libfmp4.hls.Playlist:
        return Format.M3U8_MEDIA
    elif type(manifest) == libfmp4.mpd.Manifest:
        return Format.MPD
    else:
        raise Exception(f"Unknown manifest format {type(manifest)}!")
