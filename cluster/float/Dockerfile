FROM ubuntu:18.04

# install deps
RUN apt-get update && \
	apt-get install -y \
	gdebi-core \
	wget

# get license server binaries
RUN wget https://s3.amazonaws.com/rstudio-license-server/rsp-license-server-1.0.9-x86_64.deb \
	-O rsp-license-server.deb && \
	gdebi -n rsp-license-server.deb

COPY ./float/start-licensed.sh /start-licensed.sh
ENTRYPOINT [ "/start-licensed.sh" ]
EXPOSE 8989
