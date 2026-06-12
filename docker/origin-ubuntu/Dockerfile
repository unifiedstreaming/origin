ARG UBUNTUVERSION=jammy
FROM ubuntu:$UBUNTUVERSION

ARG ARCH=amd64
ARG DIST=jammy
ARG REPO=https://beta.apt.unified-streaming.com/
ARG VERSION=1.15.23

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y wget gnupg curl
# Setup USP repositories
RUN wget https://stable.apt.unified-streaming.com/unifiedstreaming.pub \
    && apt-key add unifiedstreaming.pub \
    && echo "deb [arch=$ARCH] $REPO $DIST multiverse" > /etc/apt/sources.list.d/usp.list

# install origin
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install apache2 \
        libapache2-mod-wsgi-py3 \
    && if [ -z "$VERSION" ]; then \
            apt-get -y install libapache2-mod-smooth-streaming; \
        else \
            apt-get -y install \
                libapache2-mod-smooth-streaming=$VERSION\* \
                libapache2-mod-unified-s3-auth=$VERSION\* \
                mp4split=$VERSION\* \
                manifest-edit=$VERSION\* \
                python3-pip; \
        fi

# Yeah, not ideal, I know. Just testing for the moment. Best way would be
# create a venv, install dependencies there and then pass the venv path
# to mod-wsgi with the python-home or python-path directives. If you do that
# make sure the same python is used than the one mod_wsgi was compiled with.
RUN python3 -m pip install requests

# apache conf
COPY conf /etc/apache2

# config stuffs
RUN a2dismod mpm_prefork mpm_event \
    && a2enmod mpm_worker mod_smooth_streaming wsgi rewrite\
    && a2dissite 000-default \
    && a2ensite unified-origin

# cleanup
RUN rm /etc/apache2/sites-available/000-default.conf \
       /etc/apache2/sites-available/default-ssl.conf \
       /etc/ssl/certs/ssl-cert-snakeoil.pem \
       /etc/ssl/certs/ca-certificates.crt \
       /etc/ssl/private/ssl-cert-snakeoil.key \
    && update-ca-certificates --fresh

# Copy webpage
COPY html /var/www/unified-origin/

# entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# create folder for wsgi entrypoints
RUN mkdir -p /var/www/unified-origin/wsgi-scripts

EXPOSE 80
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["-D", "FOREGROUND"]