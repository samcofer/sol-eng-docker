FROM ubuntu:18.04

# install deps
RUN apt-get update && \
	apt-get install -y \
	gdebi-core \
	wget

# install license server binary
ARG PRODUCT=rsp
ARG VERSION=1.0.9
ARG PORT=8989
RUN wget https://s3.amazonaws.com/rstudio-license-server/${PRODUCT}-license-server-${VERSION}-x86_64.deb \
	-O ${PRODUCT}-license-server.deb && \
	gdebi -n ${PRODUCT}-license-server.deb && \
	rm ${PRODUCT}-license-server.deb

COPY ./float/start-licensed.sh /start-licensed.sh
COPY ./float/${PRODUCT}-license-server.conf /etc/${PRODUCT}-license-server.conf
ENTRYPOINT [ "/start-licensed.sh" ]
EXPOSE ${PORT}
