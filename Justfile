

update-ssl-ca:
	#!/bin/bash
	cd cluster/ssl
	./cert_authority_get.sh

regenerate-sp-certs:


clean-up-permissions:
	#!/bin/bash
	chmod 600 cluster/kerb-rsp-ha/secure-cookie-key
	chmod 600 cluster/launcher.pem
