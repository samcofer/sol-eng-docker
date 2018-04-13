PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BROWSER=firefox
DB_PASSWORD=dBp@sW0rD
PROJECT=authdocker
NETWORK=${PROJECT}_default
SCALE=1
SCALE_FIREFOX=${SCALE}
SCALE_CHROME=${SCALE}
URL=http://connect-server:6969/


ifdef DEBUG
        GRID_TIMEOUT=0
endif

test-env-up: network-up db-up

test-env-down: network-down db-down


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

kdc-up:
	NETWORK=${NETWORK} \
	docker-compose -f kerberos-base.yml up

kdc-down:
	NETWORK=${NETWORK} \
	docker-compose -f kerberos-base.yml down

ssh-up:
	NETWORK=${NETWORK} \
	docker-compose -f kerberos-base.yml -f kerberos-ssh.yml up

ssh-down:
	NETWORK=${NETWORK} \
	docker-compose -f kerberos-base.yml -f kerberos-ssh.yml down

connect-up:
	NETWORK=${NETWORK} \
	docker-compose -f kerberos-base.yml -f kerberos-ssh.yml -f raw-connect.yml up

connect-down:
	NETWORK=${NETWORK} \
	docker-compose -f kerberos-base.yml -f kerberos.ssh.yml -f raw-connect.yml down

db-up-%:
        NETWORK=${NETWORK} \
        DB_PASSWORD=${DB_PASSWORD} \
        docker-compose -f docker/$*.yml -p ${PROJECT} up -d ;\
        if [ "$*" = "db2" ] ; then \
                # need to check to make sure the container is up...
                # sleep first?  wait?  NETWORK=${NETWORK} \
                docker-compose -f docker/$*.yml -p ${PROJECT} exec db2 su - db2inst1 -c "db2 create db test"; \
        fi;

db-down-%:
        NETWORK=${NETWORK} \
        docker-compose -f docker/$*.yml -p ${PROJECT} down


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

