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
	curl \
	git \
	g++ \
	libblas3 \
	libicu52 \
	liblapack3 \
	libxml2-dev \
	libxt6 \
	make

# Get $R_VERSION
RUN mkdir -p /opt/R && cd /opt/R \
    && curl https://cdn.rstudio.com/r/ubuntu-1404/R-${R_VERSION}-ubuntu-1404.tar.gz \
      | tar xzvf - -C /opt/R/

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

