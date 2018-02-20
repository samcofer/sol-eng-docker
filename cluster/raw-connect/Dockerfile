FROM ubuntu:xenial
ENV DEBIAN_FRONTEND=noninteractive  

RUN apt-get update -y -qq && \
    apt-get install -y \
    build-essential \
    curl \
    gdebi-core \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    lsb-release \
    ntp \
    rrdtool \
    vim \
    wget

# install R apt
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN echo "deb https://cran.rstudio.com/~/ubuntu $(lsb_release -cs)/" >> /etc/apt/sources.list.d/cran-rstudio.list
RUN apt-get install -y apt-transport-https \
	r-base

# Install Connect
ARG CONNECT_BINARY_URL
RUN wget $CONNECT_BINARY_URL -O /rstudio-connect.deb && \
    gdebi -n rstudio-connect.deb && \
    rm /rstudio-connect.deb

RUN wget -O /usr/local/bin/dumb-init https://github.com/~nit_1.1.3_amd64 && chmod +x /usr/local/bin/dumb-init

COPY ./raw-connect/rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg

# because licensing
RUN apt-get -y install sudo
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# ssh & kerberos
RUN apt-get install -y \
    openssh-client \
    krb5-user \
    libpam-krb5

COPY krb5.conf /etc/krb5.conf

COPY ssh_config /etc/ssh/ssh_config

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d && \
	mkdir -p /var/log/supervisord


# create users
COPY users /tmp/users
RUN awk ' { pass=system("openssl passwd -1 "$2); system("useradd -m -p "pass" -s /bin/bash "$1) } ' /tmp/users && \
        rm /tmp/users


# need a command to set up the license manager (with an ARG?)
CMD dumb-init /opt/rstudio-connect/bin/connect --config /etc/rstudio-connect/rstudio-connect.gcfg
