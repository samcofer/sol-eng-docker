FROM rstudio/base-rsp

RUN apt-get update && apt-get install -y curl jq

COPY ./ssl/cert_get.sh /cert_get.sh
COPY ./ssl-proxy-rsp/cert_config.json /cert_config.json
COPY ./ssl-proxy-rsp/docker-entrypoint.sh /docker-entrypoint.sh

