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
RUN RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION=$RSTUDIO_LATEST || true \
  && wget -q http://download2.rstudio.org/rstudio-server-pro-${RSTUDIO_VERSION}-amd64.deb \
  && gdebi -n rstudio-server-pro-${RSTUDIO_VERSION}-amd64.deb \
  ## use more robust file locking to avoid errors when using shared volumes:
  && echo 'lock-type=advisory' >> /etc/rstudio/file-locks

# add dumb-init init system
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 \
  && chmod +x /usr/local/bin/dumb-init

COPY rstudio-proxy/supervisord.conf /etc/supervisord.conf
COPY ssh_config /etc/ssh/ssh_config

COPY rstudio-proxy/rserver.conf /etc/rstudio/rserver.conf
COPY secure-proxy-user-header /etc/rstudio/secure-proxy-user-header

COPY users /tmp/users
RUN awk ' { system("useradd -m -s /bin/bash "$1" && echo "$1":"$2" | chpasswd") } ' /tmp/users && \
	rm /tmp/users && \
	chmod 0600 /etc/rstudio/secure-proxy-user-header


COPY ./base-rsp/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/docker-entrypoint.sh"]
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0"]

EXPOSE 8787

