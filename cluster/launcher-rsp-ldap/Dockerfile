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

COPY ./launcher-rsp-ldap/rserver.conf /etc/rstudio/rserver.conf
COPY ./launcher-rsp-ldap/supervisor.sh /supervisor.sh

# debugging tools
RUN apt-get install -y curl strace nfs-common vim sssd sssd-ldap

EXPOSE 8787

# configure ldap
COPY ./sssd.conf /etc/sssd/sssd.conf
COPY ./rstudio-sssd /etc/pam.d/rstudio
COPY ./rstudio-session-sssd /etc/pam.d/rstudio-session

ENV S6_VERSION=${S6_VERSION:-v1.21.4.0}
RUN wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  && mkdir -p /etc/services.d/rstudio

COPY ./launcher-rsp-ldap/run /etc/services.d/rstudio/run
COPY ./launcher-rsp-ldap/finish /etc/services.d/rstudio/finish

# adhoc fixes to make it work...
RUN chmod -R 777 /etc/services.d/rstudio && \
	chmod 600 /etc/sssd/sssd.conf

CMD ["/init"]
