from wsgiref.util import request_uri
from pprint import pformat
from urllib.parse import urlparse, urlunparse
import requests

# Should be set as an env by Apache probably
APACHE_PROXY_PATH = "/manifest-edit"
APACHE_UPSTREAM_NETLOC = "localhost"


def _remove_apache_proxy_path(url):
    parsed_url = urlparse(url)
    parsed_url = parsed_url._replace(netloc=APACHE_UPSTREAM_NETLOC)
    parsed_url = parsed_url._replace(
        path=parsed_url.path.replace(APACHE_PROXY_PATH, "")
    )
    return urlunparse(parsed_url)


def application(environ, start_response):
    requested_origin_url = request_uri(environ, include_query=True)
    output = bytes(
        f"You have requested the path {requested_origin_url}. The environ is:\n",
        "utf-8",
    )
    output += bytes(pformat(environ, indent=4, sort_dicts=True), "utf-8")

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

    status_code = f"{response.status_code}"
    # Does the following always work?
    headers = [(k, v) for k, v in response.headers.items()]
    content = response.content

    # response_headers = [('Content-type', 'text/plain'),
    #                     ('Content-Length', str(len(output)))]
    start_response(status_code, headers)

    return [content]
