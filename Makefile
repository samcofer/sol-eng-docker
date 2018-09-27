PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PROJECT=auth-docker
NETWORK=${PROJECT}_default
SCALE=1


test-env-up: network-up db-up

test-env-down: network-down db-down


kerb-up: network-up kerb-server-up kerb-ssh-up kerb-rsp-up kerb-rsc-up

kerb-down: kerb-rsc-down kerb-rsp-down kerb-ssh-down kerb-server-down


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
# Kerberos
#---------------------------------------------
kerb-server-up:
	NETWORK=${NETWORK} \
        docker-compose -f kerberos-base.yml -f make-network.yml up -d

kerb-server-down:
	NETWORK=${NETWORK} \
        docker-compose -f kerberos-base.yml -f make-network.yml down k-server k-simple-client

kerb-ssh-up:
	NETWORK=${NETWORK} \
        docker-compose -f kerberos-base.yml -f kerberos-ssh.yml -f make-network.yml up -d

kerb-ssh-down:
	NETWORK=${NETWORK} \
        docker-compose -f kerberos-base.yml -f kerberos-ssh.yml -f make-network.yml down k-ssh-server k-ssh-client

kerb-rsp-up:
	NETWORK=${NETWORK} \
        docker-compose -f kerberos-base.yml -f kerberos-rstudio.yml -f make-network.yml up -d

kerb-rsp-down:
	NETWORK=${NETWORK} \
        docker-compose -f kerberos-base.yml -f kerberos-rstudio.yml -f make-network.yml down k-rstudio

kerb-rsc-up:
	NETWORK=${NETWORK} \
	CONNECT_LICENSE=$(CONNECT_LICENSE) \
	docker-compose -f kerberos-base.yml -f kerberos-connect.yml -f make-network.yml up -d

kerb-rsc-down:
	NETWORK=${NETWORK} \
	docker-compose -f kerberos-base.yml -f kerberos-connect.yml -f make-network.yml down k-connect
#---------------------------------------------
# Proxy 
#---------------------------------------------
apache-auth-up:
	NETWORK=${NETWORK} \
        RSP_LICENSE=$(RSP_LICENSE) \
        docker-compose -f apache-auth.yml -f make-network.yml up -d

apache-auth-down:
	NETWORK=${NETWORK} \
        docker-compose -f apache-auth.yml -f make-network.yml down

#apache-simple-up:
#	NETWORK=${NETWORK} \
#        RSP_LICENSE=$(RSP_LICENSE) \
#        docker-compose -f apache-simple.yml -f base-rsp.yml -f base-ssp.yml -f make-network.yml up -d
#
#apache-simple-down:
#	NETWORK=${NETWORK} \
#        docker-compose -f apache-simple.yml -f base-rsp.yml -f base-ssp.yml -f make-network.yml down
#
#---------------------------------------------
# OAuth2 Proxy
#---------------------------------------------
proxy-oauth-up:
	NETWORK=${NETWORK} \
	docker-compose -f oauth2-proxy.yml -f make-network.yml up -d

proxy-oauth-down:
	NETWORK=${NETWORK} \
	docker-compose -f oauth2-proxy.yml -f make-network.yml down

#---------------------------------------------
# Base RSP
#---------------------------------------------
rsp-up:
	NETWORK=${NETWORK} \
	docker-compose -f base-rsp.yml -f make-network.yml up -d

rsp-down:
	NETWORK=${NETWORK} \
	docker-compose -f base-rsp.yml -f make-network.yml down

#---------------------------------------------
# Other 
#---------------------------------------------


test-build: 
	if [ ! -e "${DB2_TARGZ}" ]; then \
		aws s3 cp s3://${S3_BUCKET}/${DB2_TARGZ} ./${DB2_TARGZ}; \
	else \
		echo "DB2 ODBC tar.gz already exists.  Not pulling"; \
	fi; \
	if [ ! -e "${ORACLE_RPM}" ]; then \
		aws s3 cp s3://${S3_BUCKET}/${ORACLE_RPM} ./${ORACLE_RPM}; \
	else \
		echo "Oracle Instant Client RPM already exists.  Not pulling"; \
	fi; \
	DB2_TARGZ=${DB2_TARGZ} \
	ORACLE_RPM=${ORACLE_RPM} \
	docker-compose -f test-container.yml -p ${PROJECT} build

test-up: 
	NETWORK=${NETWORK} \
	docker-compose -f test-container.yml -p ${PROJECT} up -d

test-down:
	NETWORK=${NETWORK} \
	docker-compose -f test-container.yml -p ${PROJECT} stop test-process

#.PHONY: db-up-redshift db-down-redshift db-up-db2 db-down-db2
