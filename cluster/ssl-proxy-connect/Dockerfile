FROM rstudio/base-connect

RUN apt-get update && apt-get install -y curl jq

COPY ./ssl/cert_get.sh /cert_get.sh
COPY ./ssl-proxy-connect/cert_config.json /cert_config.json
COPY ./ssl-proxy-connect/start-licensed.sh /start-licensed.sh

