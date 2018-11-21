ARG RSP_VERSION

FROM rstudio/r-session:trusty-${RSP_VERSION}

ARG R_VERSION=3.5.1

# Add cran apt repo (and sources)
RUN apt-get update -qq && \
	apt-get install -qq -y apt-transport-https && \
	echo "deb https://cran.rstudio.com/bin/linux/ubuntu trusty-cran35/" >> /etc/apt/sources.list.d/cran-rstudio.list && \
        echo "deb-src https://cran.rstudio.com/bin/linux/ubuntu trusty-cran35/" >> /etc/apt/sources.list.d/cran-rstudio.list && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x51716619e084dab9

RUN set -x && \
	apt-get update && \
	apt-get install -y \
	libxml2-dev \
	curl \
	git

# R dependencies
RUN apt-get -y build-dep r-base

# Build $R_VERSION from source
RUN mkdir -p /opt/R && cd /opt/R \
    && wget https://cran.r-project.org/src/base/R-3/R-$R_VERSION.tar.gz \
    && tar zxvf R-$R_VERSION.tar.gz \
    && cd R-$R_VERSION  \
    && ./configure --prefix=/opt/R/$R_VERSION --enable-R-shlib \
    && make \
    && make install \
    && cd / \
    && rm -r /opt/R/R-$R_VERSION.tar.gz \
    && rm -r /opt/R/R-$R_VERSION

RUN chmod 777 /home

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

#ENV RSTUDIO_R_PRELAUNCH_SCRIPT=/prelaunch.sh

#COPY ./launcher-session/prelaunch.sh /prelaunch.sh
#COPY ./launcher-rsp/supervisor.sh /supervisor.sh

#RUN apt-get install -y strace nfs-common && mkdir -p /tmp/diagnostics

