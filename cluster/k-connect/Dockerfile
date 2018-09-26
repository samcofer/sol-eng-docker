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
    unixodbc-dev \
    vim \
    wget

# install R apt
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x51716619e084dab9
RUN echo "deb https://cran.rstudio.com/~/ubuntu $(lsb_release -cs)/" >> /etc/apt/sources.list.d/cran-rstudio.list
RUN apt-get install -y apt-transport-https \
	r-base

# Install Connect
ARG CONNECT_BINARY_URL
COPY $CONNECT_BINARY_URL /rstudio-connect.deb
RUN gdebi -n rstudio-connect.deb && \
    rm /rstudio-connect.deb

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && chmod +x /usr/local/bin/dumb-init

# because licensing
RUN apt-get -y install sudo
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# ssh & kerberos
RUN apt-get install -y \
    openssh-client \
    krb5-user \
    libpam-krb5

# create users
COPY users /tmp/users
RUN awk ' { system("useradd -m -s /bin/bash -p tmp "$1) } ' /tmp/users && \
	awk ' { system("echo "$1":"$2" | chpasswd -m ") } ' /tmp/users && \
	awk ' { system("usermod -aG rstudio-connect "$1) } ' /tmp/users && \
        rm /tmp/users


COPY ./k-connect/rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg

COPY krb5.conf /etc/krb5.conf

COPY ssh_config /etc/ssh/ssh_config

COPY pam /etc/pam.d/rstudio-connect
COPY pam-session /etc/pam.d/rstudio-connect-session

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d


# setup init
COPY ./k-connect/start-licensed.sh /start-licensed.sh
RUN chmod +x /start-licensed.sh
CMD dumb-init /start-licensed.sh /opt/rstudio-connect/bin/connect --config /etc/rstudio-connect/rstudio-connect.gcfg
