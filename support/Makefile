#!make
PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PROJECT=sol-eng-docker
NETWORK=${PROJECT}_default
SCALE=1
CONNECT_VERSION=1.8.4-11
#1.7.0-11
CONNECT_BINARY_URL=rstudio-connect_${CONNECT_VERSION}_amd64.deb

RSTUDIO_VERSION=daily
#RSTUDIO_VERSION=1.2.5033-1
#1.3.11234
#RSTUDIO_VERSION=1.3.322-1

SSP_VERSION=1.5.10.990

case-1-up:
	NETWORK=$(NETWORK) \
	RSTUDIO_VERSION=${RSTUDIO_VERSION} \
	RSP_LICENSE=$(RSP_LICENSE) \
	docker-compose -f ./compose/case-1.yml -f ../compose/make-network.yml up -d

case-1-down:
	NETWORK=$(NETWORK) \
	docker-compose -f ./compose/case-1.yml -f ../compose/make-network.yml down

connect-up:
	NETWORK=${NETWORK} \
	RSC_LICENSE=$(RSC_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml up -d && \
	../bin/pdocker ps compose_connect

connect-restart:
	../bin/pdocker restart compose_connect_1

connect-down:
	NETWORK=${NETWORK} \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml down
