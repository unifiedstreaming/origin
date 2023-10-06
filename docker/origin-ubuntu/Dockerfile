ARG UBUNTUVERSION=jammy
FROM ubuntu:$UBUNTUVERSION

ARG ARCH=amd64
ARG DIST=jammy
ARG REPO=https://beta.apt.unified-streaming.com/
ARG VERSION=1.12.11

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y wget gnupg curl
# Setup USP repositories
RUN wget https://stable.apt.unified-streaming.com/unifiedstreaming.pub \
    && apt-key add unifiedstreaming.pub \
    && echo "deb [arch=$ARCH] $REPO $DIST multiverse" > /etc/apt/sources.list.d/usp.list

# install origin
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install apache2 \
    && if [ -z "$VERSION" ]; then \
            apt-get -y install libapache2-mod-smooth-streaming; \
        else \
            apt-get -y install \
                libapache2-mod-smooth-streaming=$VERSION \
                libapache2-mod-unified-s3-auth=$VERSION \
                mp4split=$VERSION \
                manifest-edit=$VERSION; \
        fi

# config stuffs
RUN a2dismod mpm_prefork mpm_event \
    && a2enmod mpm_worker mod_smooth_streaming \
    && a2dissite 000-default

# Copy webpage
COPY html /var/www/unified-origin/

# entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# apache conf
COPY conf /etc/apache2

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["-D", "FOREGROUND"]