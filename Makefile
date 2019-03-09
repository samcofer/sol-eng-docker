#!make
PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PROJECT=auth-docker
NETWORK=${PROJECT}_default
SCALE=1
CONNECT_VERSION=1.7.1-4265
#1.7.0-11
CONNECT_BINARY_URL=rstudio-connect_${CONNECT_VERSION}_amd64.deb

RSTUDIO_VERSION=1.2.1186-1

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

mail-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/mail.yml -f compose/make-network.yml up -d

mail-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/mail.yml -f compose/make-network.yml down

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

#---------------------------------------------
# Base Products
#---------------------------------------------
connect-up: download-connect connect-up-hide
connect-up-hide:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml up -d

 #--scale connect=2
connect-build:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml build

connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/base-connect.yml -f compose/make-network.yml down

rsp-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/base-rsp.yml -f compose/make-network.yml up -d

rsp-build:
	NETWORK=${NETWORK} \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/base-rsp.yml -f compose/make-network.yml build

rsp-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/base-rsp.yml -f compose/make-network.yml down

ssp-up:
	NETWORK=${NETWORK} \
	SSP_LICENSE=$(SSP_LICENSE) \
	docker-compose -f compose/base-ssp.yml -f compose/make-network.yml up -d
ssp-build:
	NETWORK=${NETWORK} \
	docker-compose -f compose/base-ssp.yml -f compose/make-network.yml build
ssp-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/base-ssp.yml -f compose/make-network.yml down

#---------------------------------------------
# Kubernetes
#---------------------------------------------

k8s-down: k8s-launcher-ldap-down \
	k8s-rsp-ldap-down \
	k8s-ldap-down \
	k8s-nfs-pv-down \
	k8s-nfs-down \
	k8s-launcher-ldap-config-down \
	k8s-secret-rsp-down

k8s-up: k8s-setup \
	k8s-secret-rsp \
	k8s-launcher-ldap-config \
	k8s-nfs-up \
	k8s-nfs-ip-fix \
	k8s-nfs-pv-up \
	k8s-ldap-up \
	k8s-rsp-ldap-up \
	k8s-launcher-ldap-up


k8s-ldap-all-up: k8s-setup k8s-nfs-up k8s-nfs-ip-fix k8s-nfs-pv-up \
	k8s-secret-rsp k8s-ldap-up \
	k8s-rsp-ldap-up k8s-launcher-ldap-up

k8s-ldap-all-down: k8s-launcher-ldap-down k8s-rsp-ldap-down \
	k8s-ldap-down k8s-nfs-pv-down \
	kubectl --namespace=rstudio delete secret license \
	k8s-nfs-down

k8s-setup:
	./k8s/setup.sh

#k8s-helpers:
#	source ./k8s/helpers.sh

k8s-nfs-up:
	kubectl --namespace=rstudio apply -f ./k8s/nfs.yml
k8s-nfs-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./k8s/nfs.yml

k8s-nfs-ip-fix:
	./k8s/ip_hack.sh

k8s-nfs-pv-up:
	echo 'be sure the IP is set properly in ./k8s/pv.yml !!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	kubectl --namespace=rstudio apply -f ./k8s/pv.yml
k8s-nfs-pv-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./k8s/pv.yml


k8s-nfs-launcher-mounts:
	kubectl create configmap --namespace=rstudio launcher-mounts --from-file ./cluster/launcher-rsp-ldap/launcher-mounts

k8s-launcher-keys:
	kubectl create configmap --namespace=rstudio launcher-pem --from-file ./cluster/launcher.pem && \
	kubectl create configmap --namespace=rstudio launcher-pub --from-file ./cluster/launcher.pub

k8s-launcher-ldap-config:
	kubectl create configmap --namespace=rstudio launcher-config \
		--from-file ./cluster/launcher.pem \
		--from-file ./cluster/launcher.pub \
		--from-file ./cluster/launcher-rsp-ldap/launcher-mounts \
		--from-file ./cluster/launcher-ldap/launcher.kubernetes.profiles.conf \
		--from-file ./cluster/launcher-ldap/launcher.conf \
		--from-file ./cluster/launcher-rsp-ldap/rserver.conf

k8s-launcher-ldap-config-down:
	kubectl delete --namespace=rstudio --ignore-not-found=true configmap launcher-config

k8s-launcher-k8s-prof-conf:
	kubectl create configmap --namespace=rstudio launcher-k8s-prof-conf --from-file ./cluster/launcher-ldap/launcher.kubernetes.profiles.conf
k8s-launcher-k8s-prof-conf-down:
	kubectl delete configmap --namespace=rstudio launcher-k8s-prof-conf

k8s-launcher-k8s-conf:
	kubectl create configmap --namespace=rstudio launcher-k8s-conf --from-file ./cluster/launcher-ldap/launcher.kubernetes.conf
k8s-launcher-k8s-conf-down:
	kubectl delete configmap --namespace=rstudio launcher-k8s-conf

k8s-launcher-conf:
	kubectl create configmap --namespace=rstudio launcher-conf --from-file ./cluster/launcher-ldap/launcher.conf
k8s-launcher-conf-down:
	kubectl delete configmap --namespace=rstudio launcher-conf

k8s-secret-rsp:
	kubectl --namespace=rstudio create secret generic license --from-file=./k8s/rsp

k8s-secret-rsp-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true secret license

k8s-ldap-up:
	kubectl --namespace=rstudio apply -f ./k8s/ldap.yml
k8s-ldap-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./k8s/ldap.yml

k8s-launcher-up:
	echo 'be sure the IP is set properly in ./cluster/launcher-rsp/launcher-mounts!!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	kubectl --namespace=rstudio apply -f ./k8s/launcher.yml
k8s-launcher-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./k8s/launcher.yml

k8s-launcher-ldap-up:
	echo 'be sure the IP is set properly in ./cluster/launcher-rsp/launcher-mounts!!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	kubectl --namespace=rstudio apply -f ./k8s/launcher-ldap.yml
k8s-launcher-ldap-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./k8s/launcher-ldap.yml

k8s-rsp-up:
	kubectl --namespace=rstudio apply -f ./k8s/rsp.yml
k8s-rsp-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./k8s/rsp.yml

k8s-rsp-ldap-up:
	kubectl --namespace=rstudio apply -f ./k8s/rsp-ldap.yml
k8s-rsp-ldap-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./k8s/rsp-ldap.yml

launcher-session-build:
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
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

proxy-basic-up:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml up -d nginx-support-ssp

proxy-basic-down:
	NETWORK=${NETWORK} \
        docker-compose -f compose/proxy-basic.yml -f compose/make-network.yml stop nginx-support-ssp

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

proxy-rsp-up:
	NETWORK=${NETWORK} \
	RSP_LICENSE=$(RSP_LICENSE) \
	RSTUDIO_VERSION=$(RSTUDIO_VERSION) \
	docker-compose -f compose/proxy-rsp.yml -f compose/make-network.yml up -d

proxy-rsp-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-rsp.yml -f compose/make-network.yml down

proxy-debug-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-debug.yml -f compose/make-network.yml up -d

proxy-debug-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-debug.yml -f compose/make-network.yml down

proxy-mitm-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/proxy-mitm.yml -f compose/make-network.yml up -d
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

proxy-saml-up:
	NETWORK=${NETWORK} \
	docker-compose -f compose/apache-saml.yml -f compose/make-network.yml up -d

proxy-saml-build:
	NETWORK=${NETWORK} \
	docker-compose -f compose/apache-saml.yml -f compose/make-network.yml build

proxy-saml-restart:
	NETWORK=${NETWORK} \
	docker-compose -f compose/apache-saml.yml -f compose/make-network.yml restart

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
	CONNECT_VERSION=$(CONNECT_VERSION) \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml up -d

ldap-connect-build: download-connect ldap-connect-build-hide
ldap-connect-build-hide:
	NETWORK=${NETWORK} \
	CONNECT_BINARY_URL=${CONNECT_BINARY_URL} \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml build

ldap-connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f compose/ldap-connect.yml -f compose/make-network.yml down


pg-up: 
	NETWORK=${NETWORK} \
	docker-compose -f compose/pg.yml -f compose/make-network.yml up -d
pg-down: 
	NETWORK=${NETWORK} \
	docker-compose -f compose/pg.yml -f compose/make-network.yml down
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
