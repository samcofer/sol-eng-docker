FROM rstudio/r-base:3.6-bionic

ARG SSP_VERSION=$SSP_VERSION
RUN apt-get update && apt-get install -y gdebi-core && \
	wget https://s3.amazonaws.com/rstudio-shiny-server-pro-build/ubuntu-14.04/x86_64/shiny-server-commercial-${SSP_VERSION}-amd64.deb \
	-O shiny-server.deb && \
	gdebi -n shiny-server.deb

RUN wget -O libssl1.0.0.deb http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
    && gdebi -n libssl1.0.0.deb

RUN R -e 'install.packages(c("shiny", "rmarkdown"), repos = "https://demo.rstudiopm.com/cran/__linux__/bionic/latest")'

# install dumb-init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
	chmod +x /usr/local/bin/dumb-init

# setup init
COPY ./base-ssp/start-licensed.sh /start-licensed.sh
COPY ./base-ssp/start-licensed-float.sh /start-licensed-float.sh
RUN chmod +x /start-licensed.sh && chmod +x /start-licensed-float.sh
ENTRYPOINT [ "dumb-init", "/start-licensed.sh" ]
CMD [ "shiny-server" ]

ENV SSP_LICENSE=${SSP_LICENSE}
