from wsgiref.util import request_uri
from pprint import pformat
from urllib.parse import urlparse, urlunparse
import requests
import manifest_edit.libfmp4 as libfmp4

# Should be set as an env by Apache probably
APACHE_PROXY_PATH = "/manifest-edit"
APACHE_UPSTREAM_NETLOC = "localhost"


def _remove_apache_proxy_path(url):
    # FIXME:
    # Instead of just forwarding the http verb, it makes sense to just
    # always perform a GET.
    # If the client requested a HEAD, a GET should be performed and then
    # the body dropped
    # Any other verb should probably just not be supported
    parsed_url = urlparse(url)
    parsed_url = parsed_url._replace(netloc=APACHE_UPSTREAM_NETLOC)
    parsed_url = parsed_url._replace(
        path=parsed_url.path.replace(APACHE_PROXY_PATH, "")
    )
    return urlunparse(parsed_url)


def application(environ, start_response):
    requested_origin_url = request_uri(environ, include_query=True)

    # There may be a body to read, unless we choose to just support
    # GET and HEAD (which we probably should)
    try:
        request_body_size = int(environ.get("CONTENT_LENGTH", 0))
        request_body = environ["wsgi.input"].read(request_body_size)
    except ValueError:
        request_body = b""

    request_method = environ.get("REQUEST_METHOD", "")

    # from the uri requested to apache, let's build the upstream uri to
    # get the manifest: http://my.origin<APACHE_PROXY_PATH>/foo.ism/.mpd
    # will be turned into http://localhost/foo.ism/.mpd
    upstream_uri = _remove_apache_proxy_path(requested_origin_url)

    # perform synchronous request and read all the body
    response = requests.request(request_method, upstream_uri, data=request_body)

    # We have the manifest. Now we should:
    # - load pipeline configuration file
    # - process the manifest
    # - adjust content length
    # - recompute Etag
    # 

    status_code = f"{response.status_code}"
    # Does the following always work?
    headers = [(k, v) for k, v in response.headers.items()]
    content = response.content

    # response_headers = [('Content-type', 'text/plain'),
    #                     ('Content-Length', str(len(output)))]
    start_response(status_code, headers)

    return [content]
