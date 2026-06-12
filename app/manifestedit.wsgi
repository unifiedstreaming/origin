from wsgiref.util import request_uri
from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse
import requests
import manifest_edit.libfmp4 as libfmp4
import configparser
import os
import sys
import manifests
from functools import lru_cache

# MANDATORY ENV VARS:
# - pipeline: the path to the pipeline config file to use for manifest edit.
# - config_param: the name of the query parameter used by Apache to
#   understand this is a manifest_edit request. Needs to be removed from the
#    upstream url
# - proxy_path: the path prefix used by Apache to route manifest edit requests
#    the WSGI app. Needs to be removed from the upstream url and is used to
#    understand which part of the original url is the path to the manifest.
MANDATORY_ENV_VARS = {"pipeline": None, "config_param": None, "proxy_path": None}

# Should be set as an env by Apache probably
APACHE_PROXY_PATH = "/manifest-edit"
UPSTREAM_NETLOC = "127.0.0.1"

s = requests.Session()


def _get_upstream_from(url, environ):
    """
    In order to get the upstream manifest URL, we need to perform some
    transformations to the original URL requested to Apache.
    The main transformations are:
    - change the netloc to point to 127.0.0.1, this should be the most efficient
        way to perform a "localhost" request
    - remove the query parameter used by Apache to understand this is a manifest
        edit request and not a normal request. Failure to do so will end up
        in the upstream request being mapped to manifest edit again causing
        an infinite loop.
    - remove the path prefix used by Apache to route manifest edit requests to
        the WSGI app. This is needed to get the correct path to the manifest in
        the upstream request and to avoid again an endless loop.
    Example:

        Apache: http://myorigin.internal/manifest-edit/manifest.ism/.mpd?python_config=/etc/manifest-edit/conf/mpd/my_use_case.yaml

        becomes

        Upstream: http://127.0.0.1/manifest.ism/.mpd
    """

    parsed_url = urlparse(url)
    query_parts = [
        (key, value)
        for key, value in parse_qsl(parsed_url.query, keep_blank_values=True)
        if key != MANDATORY_ENV_VARS["config_param"]
    ]
    parsed_url = parsed_url._replace(
        netloc=UPSTREAM_NETLOC,
        query=urlencode(query_parts),
    )
    parsed_url = parsed_url._replace(
        path=parsed_url.path.replace(MANDATORY_ENV_VARS["proxy_path"], "")
    )
    return urlunparse(parsed_url)


### Some utilities to return 405 or 500 statuses
def _method_not_allowed(start_response):
    output = b"Only HEAD and GET methods are allowed by Manifest Edit\n"
    status_code = "405 Method not Allowed"
    response_headers = [
        ("Content-type", "text/plain"),
        ("Content-Length", str(len(output))),
    ]
    start_response(status_code, response_headers)
    return [output]


def _raise_500_with_msg(start_response, message):
    output = bytes(message + "\n", "utf-8)")
    status_code = "500 Internal Server Error"
    response_headers = [
        ("Content-type", "text/plain"),
        ("Content-Length", str(len(output))),
    ]
    start_response(status_code, response_headers)
    return [output]


def _get_request_body(environ):
    """
    Reads the requests's body (e.g for POST).
    """
    try:
        request_body_size = int(environ.get("CONTENT_LENGTH", 0))
        request_body = environ["wsgi.input"].read(request_body_size)
    except ValueError:
        request_body = b""

    return request_body


### Utility functions taken directly from manifest edit cli code
def get_format_from_yaml(yaml_name):
    try:
        with open(yaml_name, "r") as yaml_file:
            for line in yaml_file:
                before, sep, after = line.partition(":")
                if sep == ":" and before in ("mpd", "m3u8_main", "m3u8_media"):
                    return before
        raise Exception(f"ERROR: unknown manifest format in {yaml_name}")
    except Exception:
        raise Exception(f"ERROR: Can't open {yaml_name}")


def get_default_python_path():
    if os.name == "posix":
        config_base_path = "/etc/manifest-edit"
    elif os.name == "nt":
        try:
            config_base_path = os.path.abspath(sys.modules["__main__"].__file__)
        except AttributeError:
            config_base_path = sys.executable
        config_base_path = os.path.join(os.path.dirname(config_base_path), "etc")
    else:
        return None

    cp = configparser.ConfigParser()
    cp.read(os.path.join(config_base_path, "conf", "manifest-edit.conf"))
    if "manifest-edit" in cp and "default_python_path" in cp["manifest-edit"]:
        config_base_path = cp["manifest-edit"]["default_python_path"]

    return os.path.join(config_base_path, "plugins")


# Caching based on yaml config file content allows to unnecessarily repeat, at
# each call, the yaml parsing and Schema checking parts as well as pipeline
# building, while still allowing users to change yaml configuration files
# content without needing to restart Apache.
# By default only saves last 128 function calls results.
@lru_cache
def get_pipeline_from_buffer(ep, buffer):
    return ep.Pipeline.build_pipeline_from_string(buffer)


# We could also decide to memoize this function, but it will mean that, once
# a given yaml file has been loaded, changes won't affect Manifest Edit
# untile a restart.
def get_pipeline(ep, python_pipeline_config):
    with open(python_pipeline_config, "rb") as stream:
        buffer = stream.read()

    return get_pipeline_from_buffer(ep, buffer)


def manifest_edit(manifest, python_pipeline_config):
    """
    Takes a byte string with the content of the original manifest as generated
    by the Origin and edits it based on the pipeline config file. Returns a
    byte string representation of the edited manifest.
    """
    if not python_pipeline_config:
        raise Exception("You have not provided a pipeline file!")

    # Set python path or imports will not work
    python_path = get_default_python_path()
    if python_path is not None:
        python_path_parts = python_path.split(os.pathsep)
        sys.path[1:1] = python_path_parts

    import manifest_edit.entrypoints as ep

    # loads a pipeline description, imports all needed plugins, configures
    # them and sets up the processing pipeline.
    # ep.setup(python_pipeline_config)
    ep.Context.pipeline = get_pipeline(ep, python_pipeline_config)

    # Interprets the byte string and converts it to the right manifest type
    # of libfmp4
    fmp4_manifest = manifests.from_bytes(manifest)

    # Invokes pipeline processing
    new_manifest = ep.update_manifest(libfmp4.Context(), fmp4_manifest)

    return bytes(str(new_manifest), "utf-8")


def _check_mandatory_env_vars(start_response, environ):
    message = ""
    for var in MANDATORY_ENV_VARS:
        if var not in environ:
            message += f"Mandatory env variable '{var}' not found in Apache config. Please check your Apache configuration and make sure to set it.\n"

    return _raise_500_with_msg(start_response, message)


def application(environ, start_response):
    request_method = environ.get("REQUEST_METHOD", "")

    # Only accept HEAD and GET
    if request_method not in ["GET", "HEAD"]:
        return _method_not_allowed(start_response)

    # Check presence of mandatory env vars
    MANDATORY_ENV_VARS.update(
        {k: environ[k] for k in MANDATORY_ENV_VARS if k in environ}
    )
    if any(var is None for var in MANDATORY_ENV_VARS):
        return _check_mandatory_env_vars(start_response, environ)

    original_requested_url = request_uri(environ, include_query=True)

    # There may be a body to read, but since we just support GET and HEAD
    # we can just skip it
    # request_body = _get_request_body(environ)

    # from the uri requested to apache, let's build the upstream uri to
    # get the manifest
    upstream_uri = _get_upstream_from(original_requested_url, environ)

    # perform synchronous GET request to the Origin and reads all the body
    response = s.get(upstream_uri)
    content = response.content

    # If the response is 200 OK, we have a manifest. Now we can invoke
    # manifest edit
    # FIXME: recompute Etag after getting an edited manifest?
    if response.status_code == 200:
        try:
            content = manifest_edit(content, f'{environ.get("pipeline", "")}')

            # Adjusts content length
            response.headers["Content-Length"] = f"{len(content)}"
        except Exception as e:
            return _raise_500_with_msg(
                start_response, f"Manifest Edit failed with error:\n{e}"
            )

    # Building a wsgi response from a requests response requires some
    # "translation". A complete status code "200 OK" must be assembled
    # using status_code and reason
    wsgi_status_code = f"{response.status_code} {response.reason}"
    # Requests' Headers are stored as a dictionary. uwsgi requires them
    # to be a list of tuples, e.g.
    # response_headers = [('Content-type', 'text/plain'),
    #                     ('Content-Length', str(len(output)))]
    # This should convert correctly.
    wsgi_headers = [(k, v) for k, v in response.headers.items()]

    start_response(wsgi_status_code, wsgi_headers)

    if request_method == "HEAD":
        # drop body
        content = b""

    return [content]
