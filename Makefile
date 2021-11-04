#!make
PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PROJECT=sol-eng-docker
NETWORK=${PROJECT}_default
SCALE=1
CONNECT_VERSION=1.8.4.2-2
CONNECT_VERSION=1.8.6
CONNECT_VERSION=2021.09.0
#1.7.0-11
CONNECT_BINARY_URL=rstudio-connect_${CONNECT_VERSION}_amd64.deb

#RSTUDIO_VERSION=preview
#RSTUDIO_VERSION=1.2.5033-1
#RSTUDIO_VERSION=1.3.322-1
RSTUDIO_VERSION=1.3.1093-1
RSTUDIO_VERSION=daily
RSTUDIO_VERSION=1.4.1717-3

SSP_VERSION=1.5.10.990

test-env-up: network-up

test-env-down: network-down

check:
	./bin/check.sh

pull:
	docker pull rstudio/rstudio-workbench:${RSTUDIO_VERSION} \
	&& docker pull rstudio/rstudio-connect:${CONNECT_VERSION} \
	&& docker pull ubuntu:16.04 \
	&& docker pull kristophjunge/test-saml-idp \
	&& docker pull osixia/openldap \
	&& docker pull osixia/phpldapadmin \
	&& docker pull dtwardow/ldap-self-service-password \
	&& docker pull nginx

build: kerb-server-build kerb-ssh-build kerb-rsp-build kerb-connect-build


#---------------------------------------------
# Network
#---------------------------------------------
network-up:
	$(eval NETWORK_EXISTS=$(shell docker network inspect ${NETWORK} > /dev/null 2>&1 && echo 0 || echo 1))
	@if [ "${NETWORK_EXISTS}" = "1" ] ; then \
		echo "Creating network: ${NETWORK}"; \
		docker network create --driver bridge ${NETWORK} ; \
	fi;

network-down:
	$(eval NETWORK_EXISTS=$(shell docker network inspect ${NETWORK} > /dev/null 2>&1 && echo 0 || echo 1))
	@if [ "${NETWORK_EXISTS}" = "0" ] ; then \
		for i in `docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' ${NETWORK}`; do \
			echo "Removing container \"$${i}\" from network \"${NETWORK}\""; \
			docker network disconnect -f ${NETWORK} $${i}; \
		done; \
		echo "Removing network: ${NETWORK}"; \
		docker network rm ${NETWORK}; \
	fi;

#---------------------------------------------
# Helpers
#---------------------------------------------
download-connect:
	@if [ ! -e "./cluster/${CONNECT_BINARY_URL}" ]; then \
		echo "File ./cluster/${CONNECT_BINARY_URL} does not exist... downloading"; \
		wget https://s3.amazonaws.com/rstudio-connect/${CONNECT_BINARY_URL} \
		  -O ./cluster/${CONNECT_BINARY_URL}; \
	fi;

mail-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/mail.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps mail-ui

mail-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/mail.yml -f compose/make-network.yml down

#---------------------------------------------
# SSL
#---------------------------------------------
ssl-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps cfssl

ssl-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl.yml -f compose/make-network.yml down

ssl-proxy-connect-up: download-connect ssl-proxy-connect-up-hide
ssl-proxy-connect-up-hide:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/ssl-proxy-connect.yml -f compose/make-network.yml up -d

ssl-proxy-connect-build: download-connect ssl-proxy-connect-build-hide
ssl-proxy-connect-build-hide:
	NETWORK=${NETWORK} \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/ssl-proxy-connect.yml -f compose/make-network.yml build

ssl-proxy-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl-proxy-connect.yml down

ssl-connect-up:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/ssl-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps ssl-connect


ssl-connect-build:
	NETWORK=${NETWORK} \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/ssl-connect.yml -f compose/make-network.yml build

ssl-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl-connect.yml down

ssl-proxy-rsp-build:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	docker-compose -f compose/ssl-proxy-rsp.yml -f compose/make-network.yml build

ssl-proxy-rsp-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	docker-compose -f compose/ssl-proxy-rsp.yml -f compose/make-network.yml up -d

ssl-proxy-rsp-restart:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	docker-compose -f compose/ssl-proxy-rsp.yml -f compose/make-network.yml restart

ssl-proxy-rsp-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl-proxy-rsp.yml -f compose/make-network.yml down

load-test-build:
	docker-compose -f compose/load-test.yml build
#---------------------------------------------
# Base Products
#---------------------------------------------
connect-up:
	NETWORK=${NETWORK} \
	RSC_LICENSE=$(RSC_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps compose_connect

connect-restart:
	./bin/pdocker restart compose_connect_1

connect-down:
	NETWORK=${NETWORK} \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml down

pam-connect-up:
	NETWORK=${NETWORK} \
	RSC_LICENSE=$(RSC_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/pam-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps compose_pam-connect

pam-connect-restart:
	./bin/pdocker restart compose_pam-connect_1

pam-connect-down:
	NETWORK=${NETWORK} \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/pam-connect.yml -f compose/make-network.yml down

kerb-ldap-rsp-build:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/kerb-ldap-rsp.yml -f compose/make-network.yml build

kerb-ldap-rsp-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/kerb-ldap-rsp.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps kerb-ldap-rsp


kerb-ldap-rsp-down:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/kerb-ldap-rsp.yml -f compose/make-network.yml down

ssp-ha-up:
	NETWORK=${NETWORK} \
	SSP_LICENSE=$(SSP_LICENSE) \
	SSP_VERSION=$(SSP_VERSION) \
	docker-compose -f compose/ssp-ha.yml -f compose/make-network-3.7.yml up -d
ssp-ha-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssp-ha.yml -f compose/make-network-3.7.yml down

rsp-ha-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/rsp-ha.yml -f compose/make-network-3.7.yml up -d && \
	./bin/pdocker ps rsp

rsp-ha-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/rsp-ha.yml -f compose/make-network-3.7.yml down

nfs-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/nfs.yml -f compose/make-network.yml up -d
nfs-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/nfs.yml -f compose/make-network.yml down

launcher-up:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/launcher.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps launcher

launcher-restart:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/launcher.yml -f compose/make-network.yml restart && \
	./bin/pdocker ps launcher

launcher-down:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/launcher.yml -f compose/make-network.yml down

rsp-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/base-rsp.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps base-rsp

rsp-restart:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/base-rsp.yml -f compose/make-network.yml restart && \
	./bin/pdocker ps base-rsp

rsp-down:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/base-rsp.yml -f compose/make-network.yml down

ssp-up:
	NETWORK=${NETWORK} \
	SSP_LICENSE=$(SSP_LICENSE) \
	SSP_VERSION=${SSP_VERSION} \
	docker-compose -f compose/base-ssp.yml -f compose/make-network.yml up -d
ssp-build:
	NETWORK=${NETWORK} \
        SSP_VERSION=${SSP_VERSION} \
	docker-compose -f compose/base-ssp.yml -f compose/make-network.yml build
ssp-down:
	NETWORK=${NETWORK} \
        SSP_VERSION=${SSP_VERSION} \
	docker-compose -f compose/base-ssp.yml -f compose/make-network.yml down

ssp-float-up:
	NETWORK=${NETWORK} \
	SSP_LICENSE=$(SSP_LICENSE) \
	SSP_VERSION=${SSP_VERSION} \
	LICENSE_SERVER=float-ssp:8979 \
	docker-compose -f compose/ssp-float.yml -f compose/make-network.yml up -d

ssp-float-down:
	NETWORK=${NETWORK} \
        SSP_VERSION=${SSP_VERSION} \
	docker-compose -f compose/ssp-float.yml -f compose/make-network.yml down

#---------------------------------------------
# Kubernetes
#---------------------------------------------
k8s-%:
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) $(MAKE) -C k8s $*

launcher-session-build:
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/launcher-rsp.yml build launcher-session

r-session-debug-build:
	RSP_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/r-session-debug.yml build debug-session

#---------------------------------------------
# Support
#---------------------------------------------
s-%:
	$(MAKE) -C support $*

#---------------------------------------------
# Floating License Servers
#---------------------------------------------
float-build:
	NETWORK=${NETWORK} \
	VERSION=1.1.1 \
	docker-compose -f compose/float.yml -f compose/make-network.yml build
float-up:
	NETWORK=${NETWORK} \
	VERSION=1.1.1 \
	docker-compose -f compose/float.yml -f compose/make-network.yml up -d
float-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/float.yml -f compose/make-network.yml down

float-ha-up:
	NETWORK=${NETWORK} \
	VERSION=1.1.1 \
	RSC_FLOAT_LICENSE=$(RSC_FLOAT_LICENSE) \
	RSC_FLOAT_LICENSE_ALT=$(RSC_FLOAT_LICENSE_ALT) \
	docker-compose -f compose/float-ha.yml -f compose/make-network.yml up -d
float-ha-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/float-ha.yml -f compose/make-network.yml down

float-connect-up:
	NETWORK=${NETWORK} \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/float-connect.yml -f compose/make-network.yml up -d

float-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/float-connect.yml -f compose/make-network.yml down

#---------------------------------------------
# Kerberos
#---------------------------------------------
kerb-up: network-up kerb-server-up kerb-ssh-up kerb-rsp-up kerb-connect-up

kerb-down: kerb-connect-down kerb-rsp-down kerb-ssh-down kerb-server-down

kerb-server-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/make-network.yml up -d

kerb-server-build:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/make-network.yml build

kerb-server-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/make-network.yml down

kerb-ssh-build:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-ssh.yml -f compose/make-network.yml build
kerb-ssh-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-ssh.yml -f compose/make-network.yml up -d
kerb-ssh-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-ssh.yml -f compose/make-network.yml down

kerb-rsp-build:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
        docker-compose -f compose/kerb-rsp.yml -f compose/make-network.yml build
kerb-rsp-up:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
        docker-compose -f compose/kerb-rsp.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps kerb-rsp
kerb-rsp-test:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
        docker-compose -f compose/kerb-rsp.yml -f compose/make-network.yml run sut
kerb-rsp-test-i:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
        docker-compose -f compose/kerb-rsp.yml -f compose/make-network.yml run sut bash
kerb-rsp-down:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
        docker-compose -f compose/kerb-rsp.yml -f compose/make-network.yml down

kerb-rsp-ha-up:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
        docker-compose -f compose/kerb-rsp-ha.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps kerb-rsp-ha

kerb-rsp-ha-down:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
        docker-compose -f compose/kerb-rsp-ha.yml -f compose/make-network.yml down

kerb-proxy-up: proxy-kerb-up
kerb-proxy-down: proxy-kerb-down
kerb-proxy-build: proxy-kerb-build

kerb-connect-build:
	NETWORK=${NETWORK} \
	RSC_LICENSE=$(RSC_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/kerb-connect.yml -f compose/make-network.yml build

kerb-connect-up:
	NETWORK=${NETWORK} \
	RSC_LICENSE=$(RSC_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/kerb-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps kerb-connect

kerb-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/kerb-connect.yml -f compose/make-network.yml down

kerb-connect-test:
	NETWORK=${NETWORK} \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/kerb-connect.yml -f compose/make-network.yml run sut
kerb-connect-test-i:
	NETWORK=${NETWORK} \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/kerb-connect.yml -f compose/make-network.yml run sut bash
#---------------------------------------------
# Proxy
#---------------------------------------------
apache-auth-up:
	NETWORK=${NETWORK} \
        RSP_LICENSE=$(RSP_LICENSE) \
        docker-compose -f compose/apache-auth.yml -f compose/make-network.yml up -d

apache-auth-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/apache-auth.yml -f compose/make-network.yml down

apache-simple-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml up -d apache-simple && \
	./bin/pdocker ps apache-simple
apache-simple-restart:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml restart apache-simple && \
	./bin/pdocker ps apache-simple
apache-simple-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml stop apache-simple

apache-support-connect-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/apache-support-connect.yml -f compose/make-network.yml up -d apache-support-connect && \
	./bin/pdocker ps apache-support-connect
apache-support-connect-restart:
	NETWORK=${NETWORK} \
        docker-compose -f compose/apache-support-connect.yml -f compose/make-network.yml restart apache-support-connect && \
	./bin/pdocker ps apache-support-connect
apache-support-connect-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/apache-support-connect.yml -f compose/make-network.yml stop apache-support-connect

proxy-auth-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-auth.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps proxy-auth

proxy-auth-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-auth.yml -f compose/make-network.yml stop

proxy-basic-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml up -d nginx-support-rsp && \
	./bin/pdocker ps nginx-support-rsp

proxy-basic-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml stop nginx-support-rsp

proxy-nginx-all-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-all.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps proxy-nginx-all

proxy-nginx-all-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-all.yml -f compose/make-network.yml down

proxy-nginx-all-restart:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-all.yml -f compose/make-network.yml restart && \
	./bin/pdocker ps proxy-nginx-all

proxy-nginx-connect-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps proxy-nginx-connect

proxy-nginx-connect-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-connect.yml -f compose/make-network.yml down

proxy-nginx-connect-restart:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-connect.yml -f compose/make-network.yml restart && \
	./bin/pdocker ps proxy-nginx-connect

proxy-nginx-rstudio-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-rstudio.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps proxy-nginx-rstudio

proxy-nginx-rstudio-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-rstudio.yml -f compose/make-network.yml down

proxy-nginx-rstudio-restart:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-nginx-rstudio.yml -f compose/make-network.yml restart && \
	./bin/pdocker ps proxy-nginx-rstudio

proxy-basic-rsp-ha-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml up -d apache-support-rsp-ha

proxy-basic-rsp-ha-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml stop apache-support-rsp-ha

proxy-basic-ssp-ha-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml up -d apache-support-ssp-ha

proxy-basic-ssp-ha-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml stop apache-support-ssp-ha

#---------------------------------------------
# Proxy Products
#---------------------------------------------

proxy-connect-up:
	NETWORK=${NETWORK} \
	RSC_LICENSE=$(RSC_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/proxy-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps proxy-connect

proxy-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-connect.yml down

proxy-rsp-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/proxy-rsp.yml -f compose/make-network.yml up -d

proxy-rsp-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-rsp.yml -f compose/make-network.yml down

proxy-rsp-launcher-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/proxy-rsp-launcher.yml -f compose/make-network.yml up -d

proxy-rsp-launcher-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-rsp-launcher.yml -f compose/make-network.yml down

proxy-debug-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-debug.yml -f compose/make-network.yml up -d

proxy-debug-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-debug.yml -f compose/make-network.yml down

proxy-mitm-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-mitm.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps mitm
proxy-mitm-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-mitm.yml -f compose/make-network.yml down
#---------------------------------------------
# OAuth2 Proxy
#---------------------------------------------
proxy-oauth-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/oauth2-proxy.yml -f compose/make-network.yml up -d

proxy-oauth-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/oauth2-proxy.yml -f compose/make-network.yml down

#---------------------------------------------
# SAML Proxy
#---------------------------------------------
ssl-proxy-saml-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl-proxy-saml.yml -f compose/make-network.yml up -d

ssl-proxy-saml-build:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl-proxy-saml.yml -f compose/make-network.yml build

ssl-proxy-saml-restart:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl-proxy-saml.yml -f compose/make-network.yml restart

ssl-proxy-saml-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl-proxy-saml.yml -f compose/make-network.yml down

keycloak-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/keycloak.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps keycloak

keycloak-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/keycloak.yml -f compose/make-network.yml down

id-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/id.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps id 

id-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/id.yml -f compose/make-network.yml down

saml-idp-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/saml-idp.yml -f compose/make-network.yml up -d

saml-idp-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/saml-idp.yml -f compose/make-network.yml down

saml-connect-up:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/saml-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps saml-connect

saml-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/saml-connect.yml -f compose/make-network.yml down

oidc-connect-up:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/oidc-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps oidc-connect

oidc-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/oidc-connect.yml -f compose/make-network.yml down

saml-connect-keycloak-up:
	NETWORK=${NETWORK} \
	RSC_LICENSE=$(RSC_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/saml-connect-keycloak.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps saml-connect-keycloak

saml-connect-keycloak-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/saml-connect-keycloak.yml -f compose/make-network.yml down

proxy-saml-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-saml.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps proxy-saml

proxy-saml-build:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-saml.yml -f compose/make-network.yml build

proxy-saml-restart:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-saml.yml -f compose/make-network.yml restart

proxy-saml-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-saml.yml -f compose/make-network.yml down

proxy-kerb-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-kerb.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps proxy-kerb

proxy-kerb-build:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-kerb.yml -f compose/make-network.yml build

proxy-kerb-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-kerb.yml -f compose/make-network.yml down


#---------------------------------------------
# LDAP
#---------------------------------------------
#ldap-up: network-up ldap-server-up ldap-connect-up
#ldap-down: ldap-connect-down ldap-server-down

ldap-server-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ldap-server.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps phpldapadmin
ldap-server-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ldap-server.yml -f compose/make-network.yml down

ldap-connect-up:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps ldap-connect

ldap-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml down

ldap-connect-restart:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml restart ldap-connect && \
	./bin/pdocker ps ldap-connect

pg-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/pg.yml -f compose/make-network.yml up -d
pg-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/pg.yml -f compose/make-network.yml down

ldap-rsp-build:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/ldap-rsp.yml -f compose/make-network.yml build
ldap-rsp-up:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/ldap-rsp.yml -f compose/make-network.yml up -d && \
	./bin/pdocker ps ldap-rsp
ldap-rsp-down:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/ldap-rsp.yml -f compose/make-network.yml down

#---------------------------------------------
# Other
#---------------------------------------------

#
#test-build:
#	if [ ! -e "${DB2_TARGZ}" ]; then \
#		aws s3 cp s3://${S3_BUCKET}/${DB2_TARGZ} ./${DB2_TARGZ}; \
#	else \
#		echo "DB2 ODBC tar.gz already exists.  Not pulling"; \
#	fi; \
#	if [ ! -e "${ORACLE_RPM}" ]; then \
#		aws s3 cp s3://${S3_BUCKET}/${ORACLE_RPM} ./${ORACLE_RPM}; \
#	else \
#		echo "Oracle Instant Client RPM already exists.  Not pulling"; \
#	fi; \
#	DB2_TARGZ=${DB2_TARGZ} \
#	ORACLE_RPM=${ORACLE_RPM} \
#	docker-compose -f test-container.yml -p ${PROJECT} build
#
#test-up:
#	NETWORK=${NETWORK} \
#	docker-compose -f test-container.yml -p ${PROJECT} up -d
#
#test-down:
#	NETWORK=${NETWORK} \
#	docker-compose -f test-container.yml -p ${PROJECT} stop test-process
#
#.PHONY: db-up-redshift db-down-redshift db-up-db2 db-down-db2
