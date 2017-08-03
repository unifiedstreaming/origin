FROM alpine:3.4
LABEL maintainer "Unified Streaming <support@unified-streaming.com>"

# Install packages
RUN apk --update add apache2 \
 && rm -f /var/cache/apk/*

RUN wget -q -O /etc/apk/keys/alpine@unified-streaming.com.rsa.pub \
  http://apk.unified-streaming.com/alpine@unified-streaming.com.rsa.pub

RUN apk --update \
        --repository http://apk.unified-streaming.com/repo \
        add \
          mp4split \
          mod_smooth_streaming \
 && rm -f /var/cache/apk/*

RUN mkdir -p /run/apache2 \
 && ln -s /dev/stderr /var/log/apache2/error.log \
 && ln -s /dev/stdout /var/log/apache2/access.log \
 && mkdir -p /var/www/unified-origin

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
