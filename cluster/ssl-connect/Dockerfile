FROM rstudio/base-connect

RUN apt-get update && apt-get install -y curl jq

COPY ./ssl/cert_get.sh /cert_get.sh
COPY ./ssl-connect/cert_config.json /cert_config.json
COPY ./ssl-connect/start-licensed.sh /start-licensed.sh

