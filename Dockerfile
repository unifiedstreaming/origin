ARG ALPINEVERSION=3.14

FROM alpine:$ALPINEVERSION
LABEL maintainer "Unified Streaming <support@unified-streaming.com>"

# ARGs declared before FROM are in a different scope, so need to be stated again
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG ALPINEVERSION
ARG BETA_REPO=https://beta.apk.unified-streaming.com/alpine/
ARG STABLE_REPO=https://stable.apk.unified-streaming.com/alpine/
ARG VERSION=1.11.3

# Get USP public key
RUN wget -q -O /etc/apk/keys/alpine@unified-streaming.com.rsa.pub \
    https://stable.apk.unified-streaming.com/alpine@unified-streaming.com.rsa.pub

# Install Origin
RUN apk \
    --update \
    --repository $BETA_REPO/v$ALPINEVERSION \
    --repository $STABLE_REPO/v$ALPINEVERSION \
    add \
        apache2 \
        apache2-proxy \
        apache2-ssl \
        mp4split~$VERSION \
        mod_smooth_streaming~$VERSION \
        mod_unified_s3_auth~$VERSION \
        manifest-edit~$VERSION \
        python3 \
        py3-pip \
&&  pip3 install \
        pyyaml==5.3.1 \
        schema==0.7.3 \
&&  rm -f /var/cache/apk/*

# Set up directories and log file redirection
RUN mkdir -p /run/apache2 \
    && ln -s /dev/stderr /var/log/apache2/error.log \
    && ln -s /dev/stdout /var/log/apache2/access.log \
    && mkdir -p /var/www/unified-origin


COPY httpd.conf /etc/apache2/httpd.conf
COPY unified-origin.conf.in /etc/apache2/conf.d/unified-origin.conf.in
COPY s3_auth.conf.in /etc/apache2/conf.d/s3_auth.conf.in
COPY remote_storage.conf.in /etc/apache2/conf.d/remote_storage.conf.in
COPY transcode.conf.in /etc/apache2/conf.d/transcode.conf.in
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY index.html /var/www/unified-origin/index.html
COPY clientaccesspolicy.xml /var/www/unified-origin/clientaccesspolicy.xml
COPY crossdomain.xml /var/www/unified-origin/crossdomain.xml

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["-D", "FOREGROUND"]
