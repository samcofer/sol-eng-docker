#!make
PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PROJECT=auth-docker
NETWORK=${PROJECT}_default
SCALE=1
CONNECT_BINARY_URL=rstudio-connect_1.6.10-3_amd64.deb

RSP_VERSION=1.2.1070-1

test-env-up: network-up

test-env-down: network-down


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

#---------------------------------------------
# SSL
#---------------------------------------------
ssl-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl.yml -f compose/make-network.yml up -d

ssl-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl.yml -f compose/make-network.yml down

ssl-proxy-connect-up: download-connect ssl-proxy-connect-up-hide
ssl-proxy-connect-up-hide:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/ssl-proxy-connect.yml -f compose/make-network.yml up -d

ssl-proxy-connect-build: download-connect ssl-proxy-connect-build-hide
ssl-proxy-connect-build-hide:
	NETWORK=${NETWORK} \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/ssl-proxy-connect.yml -f compose/make-network.yml build

ssl-proxy-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ssl-proxy-connect.yml down

#---------------------------------------------
# Base Products
#---------------------------------------------
connect-up: download-connect connect-up-hide
connect-up-hide:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml up -d

connect-build:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml build

connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml down

rsp-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	docker-compose -f compose/base-rsp.yml -f compose/make-network.yml up -d

rsp-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/base-rsp.yml -f compose/make-network.yml down

ssp-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/base-ssp.yml -f compose/make-network.yml up -d

ssp-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/base-ssp.yml -f compose/make-network.yml down

#---------------------------------------------
# Kubernetes
#---------------------------------------------

k8s-ldap-all-up: k8s-setup k8s-nfs-up k8s-nfs-ip-fix k8s-nfs-pv-up \
	k8s-secret-rsp k8s-ldap-up \
	k8s-rsp-ldap-up k8s-launcher-ldap-up

k8s-ldap-all-down: k8s-launcher-ldap-down k8s-rsp-ldap-down \
	k8s-ldap-down k8s-nfs-pv-down \
	k8s-nfs-down

k8s-setup:
	./k8s/setup.sh

#k8s-helpers:
#	source ./k8s/helpers.sh

k8s-nfs-up:
	kubectl --namespace=rstudio apply -f ./k8s/nfs.yml
k8s-nfs-down:
	kubectl --namespace=rstudio delete -f ./k8s/nfs.yml

k8s-nfs-ip-fix:
	./k8s/ip_hack.sh

k8s-nfs-pv-up:
	echo 'be sure the IP is set properly in ./k8s/pv.yml !!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	kubectl --namespace=rstudio apply -f ./k8s/pv.yml
k8s-nfs-pv-down:
	kubectl --namespace=rstudio delete -f ./k8s/pv.yml

k8s-secret-rsp:
	kubectl --namespace=rstudio create secret generic license --from-file=./k8s/rsp

k8s-ldap-up:
	kubectl --namespace=rstudio apply -f ./k8s/ldap.yml
k8s-ldap-down:
	kubectl --namespace=rstudio delete -f ./k8s/ldap.yml

k8s-launcher-up:
	echo 'be sure the IP is set properly in ./cluster/launcher-rsp/launcher-mounts!!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	kubectl --namespace=rstudio apply -f ./k8s/launcher.yml
k8s-launcher-down:
	kubectl --namespace=rstudio delete -f ./k8s/launcher.yml

k8s-launcher-ldap-up:
	echo 'be sure the IP is set properly in ./cluster/launcher-rsp/launcher-mounts!!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	docker-compose -f compose/launcher-rsp-ldap.yml build launcher-ldap && \
	kubectl --namespace=rstudio apply -f ./k8s/launcher-ldap.yml
k8s-launcher-ldap-down:
	kubectl --namespace=rstudio delete -f ./k8s/launcher-ldap.yml

k8s-rsp-up:
	kubectl --namespace=rstudio apply -f ./k8s/rsp.yml
k8s-rsp-down:
	kubectl --namespace=rstudio delete -f ./k8s/rsp.yml

k8s-rsp-ldap-up:
	docker-compose -f compose/launcher-rsp-ldap.yml build launcher-rsp-ldap && \
	kubectl --namespace=rstudio apply -f ./k8s/rsp-ldap.yml
k8s-rsp-ldap-down:
	kubectl --namespace=rstudio delete -f ./k8s/rsp-ldap.yml

launcher-session-build:
	RSP_VERSION=${RSP_VERSION} \
	docker-compose -f compose/launcher-rsp.yml build launcher-session

#---------------------------------------------
# Floating License Servers
#---------------------------------------------
float-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/float.yml -f compose/make-network.yml up -d
float-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/float.yml -f compose/make-network.yml down 

#---------------------------------------------
# Kerberos
#---------------------------------------------
kerb-up: network-up kerb-server-up kerb-ssh-up kerb-rsp-up kerb-rsc-up

kerb-down: kerb-rsc-down kerb-rsp-down kerb-ssh-down kerb-server-down

kerb-server-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/make-network.yml up -d

kerb-server-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/make-network.yml stop k-server k-simple-client

kerb-ssh-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/kerberos-ssh.yml -f compose/make-network.yml up -d

kerb-ssh-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/kerberos-ssh.yml -f compose/make-network.yml stop k-ssh-server k-ssh-client

kerb-rsp-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/kerberos-rstudio.yml -f compose/make-network.yml up -d

kerb-rsp-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/kerberos-base.yml -f compose/kerberos-rstudio.yml -f compose/make-network.yml stop k-rstudio

kerb-rsc-up: download-connect kerb-rsc-up-hide
kerb-rsc-up-hide:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \ 
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/kerberos-base.yml -f compose/kerberos-connect.yml -f compose/make-network.yml up -d

kerb-rsc-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/kerberos-base.yml -f compose/kerberos-connect.yml -f compose/make-network.yml stop k-connect
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
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml up -d apache-simple

apache-simple-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml stop apache-simple

#---------------------------------------------
# Proxy Products
#---------------------------------------------

proxy-connect-up: download-connect proxy-connect-up-hide
proxy-connect-up-hide:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/proxy-connect.yml -f compose/make-network.yml up -d

proxy-connect-build: download-connect proxy-connect-build-hide
proxy-connect-build-hide:
	NETWORK=${NETWORK} \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/proxy-connect.yml -f compose/make-network.yml build

proxy-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-connect.yml down

proxy-debug-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-debug.yml -f compose/make-network.yml up -d

proxy-debug-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-debug.yml -f compose/make-network.yml down

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

proxy-saml-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/apache-saml.yml -f compose/make-network.yml up -d

proxy-saml-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/apache-saml.yml -f compose/make-network.yml down


#---------------------------------------------
# LDAP
#---------------------------------------------
ldap-up: network-up ldap-server-up ldap-connect-up
ldap-down: ldap-connect-down ldap-server-down

ldap-server-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ldap.yml -f compose/make-network.yml up -d
ldap-server-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ldap.yml -f compose/make-network.yml down

ldap-connect-up: download-connect ldap-connect-up-hide
ldap-connect-up-hide:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml up -d

ldap-connect-build: download-connect ldap-connect-build-hide
ldap-connect-build-hide:
	NETWORK=${NETWORK} \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml build

ldap-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml down

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
