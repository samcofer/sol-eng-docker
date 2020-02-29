FROM ubuntu:xenial
ENV DEBIAN_FRONTEND=noninteractive  

RUN apt-get update -y -qq && \
    apt-get install -y \
    apt-transport-https \
    build-essential \
    curl \
    gcc \
    gdebi-core \
    git \
    g++ \
    libblas3 \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libedit2 \
    liblapack3 \
    libxml2-dev \
    libssl-dev \
    libtiff5-dev \
    libxt6 \
    lsb-release \
    make \
    ntp \
    psmisc \
    rrdtool \
    unixodbc-dev \
    vim \
    wget \
    python \ 
    python-pip \ 
    python-virtualenv \
    python3 \ 
    python3-pip \
    python3-virtualenv \
    wget
# gcc & g++ are only needed as build dependencies for packages

# install R
ARG R_VERSION=3.5.1
RUN mkdir -p /opt/R && \
	curl https://cdn.rstudio.com/r/ubuntu-1604/R-${R_VERSION}-ubuntu-1604.tar.gz | \
	tar xzvf - -C /opt/R/

# Install Connect
ARG CONNECT_BINARY_URL
COPY $CONNECT_BINARY_URL /rstudio-connect.deb
RUN gdebi -n /rstudio-connect.deb && \
    rm /rstudio-connect.deb

# install dumb-init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
	chmod +x /usr/local/bin/dumb-init

# because licensing
RUN apt-get update -qq && apt-get -y install sudo
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# create users
COPY users /tmp/users
RUN awk ' { system("useradd -m -s /bin/bash -p tmp "$1) } ' /tmp/users && \
	awk ' { system("echo "$1":"$2" | chpasswd -m ") } ' /tmp/users && \
	awk ' { system("usermod -aG rstudio-connect "$1) } ' /tmp/users && \
        rm /tmp/users

COPY ./base-connect/rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg

# setup init
COPY ./base-connect/start-licensed.sh /start-licensed.sh
RUN chmod +x /start-licensed.sh
CMD dumb-init /start-licensed.sh /opt/rstudio-connect/bin/connect --config /etc/rstudio-connect/rstudio-connect.gcfg
