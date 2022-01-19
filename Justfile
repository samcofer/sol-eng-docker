

update-ssl-ca:
	#!/bin/bash
	cd cluster/ssl
	./cert_authority_get.sh

regenerate-sp-certs:


clean-up-permissions:
	#!/bin/bash
	chmod 600 cluster/kerb-rsp-ha/secure-cookie-key
        chmod 600 cluster/secure-cookie-key
	chmod 600 cluster/launcher.pem
	chmod 600 cluster/kerb-rsp-ha/database.conf
        chmod 644 cluster/kerb-rsp-ha/certs/*
