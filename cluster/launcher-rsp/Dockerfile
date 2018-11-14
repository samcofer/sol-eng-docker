# https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/devel/Dockerfile
# https://www.rstudio.com/products/rstudio/download-commercial/ 
FROM rocker/r-ver:3.4.3

ARG RSTUDIO_VERSION
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

ENV RSP_LICENSE=$RSP_LICENSE 

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y apt-transport-https && \
	apt-get dist-upgrade -y

# Install system dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    gdebi \
    git \
    libapparmor1 \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    python-setuptools \
    sudo \
    wget \
    rrdtool \
    && wget -O libssl1.0.0.deb http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
    && gdebi -n libssl1.0.0.deb

## Download and install RStudio Server Pro
## Attempts to detect latest version, otherwise falls back to version given in $VER
RUN \
  #RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  #&& [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION=$RSTUDIO_LATEST || true \
  wget -q https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-pro-1.2.1086-1-amd64.deb -O rstudio-server-pro.deb \
  #&& wget -q http://download2.rstudio.org/rstudio-server-pro-${RSTUDIO_VERSION}-amd64.deb \
  && gdebi -n rstudio-server-pro.deb \
  && rm rstudio-server-pro.deb \
  ## use more robust file locking to avoid errors when using shared volumes:
  && echo 'lock-type=advisory' >> /etc/rstudio/file-locks

# commented for now because RSP does not log well in docker :(
# add dumb-init init system
#RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 \
#  && chmod +x /usr/local/bin/dumb-init
#ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/docker-entrypoint.sh"]
#CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0"]

COPY launcher-rsp/rserver.conf /etc/rstudio/rserver.conf

#COPY users /tmp/users
#RUN awk ' { system("useradd -m -s /bin/bash "$1" && echo "$1":"$2" | chpasswd") } ' /tmp/users && \
#	rm /tmp/users

COPY ./launcher-rsp/docker-entrypoint.sh /docker-entrypoint.sh
COPY ./launcher-rsp/launcher.conf /etc/rstudio/launcher.conf

# debugging tools
RUN apt-get install -y curl strace nfs-common vim sssd

EXPOSE 8787

COPY ./launcher-rsp/supervisor.sh /supervisor.sh
COPY ./launcher-rsp/launcher-mounts /etc/rstudio/launcher-mounts

COPY ./sssd.conf /etc/sssd.conf
COPY ./rstudio-sssd /etc/pam.d/rstudio
COPY ./rstudio-session-sssd /etc/pam.d/rstudio-session

RUN wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  && mkdir -p /etc/services.d/rstudio 
  && echo '#!/usr/bin/with-contenv bash \
          \n## load /etc/environment vars first: \
            \n for line in $( cat /etc/environment ) ; do export $line ; done \
          \n exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0' \
          > /etc/services.d/rstudio/run \
  && echo '#!/bin/bash \
          \n rstudio-server stop' \
          > /etc/services.d/rstudio/finish

CMD ["/init"]
