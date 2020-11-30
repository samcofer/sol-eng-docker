# --------------------
# NEW
# --------------------
rsp-up:
	helm upgrade --install rsp soleng/rstudio-server --set license=$(RSP_LICENSE) --set userCreate=true --set rbac.create=true --set homeStorage.create=true
rsp-down:
	helm delete rsp

# --------------------
# OLD
# --------------------
down: launcher-ldap-down \
	rsp-ldap-down \
	ldap-down \
	nfs-pv-down \
	nfs-down \
	launcher-ldap-config-down \
	secret-rsp-down

up: setup \
	secret-rsp \
	launcher-ldap-config \
	nfs-up \
	nfs-ip-fix \
	nfs-pv-up \
	ldap-up \
	rsp-ldap-up \
	launcher-ldap-up

ldap-all-up: setup nfs-up nfs-ip-fix nfs-pv-up \
	secret-rsp ldap-up \
	rsp-ldap-up launcher-ldap-up

ldap-all-down: launcher-ldap-down rsp-ldap-down \
	ldap-down nfs-pv-down \
	kubectl --namespace=rstudio delete secret license \
	nfs-down

setup:
	./setup.sh

#helpers:
#	source ./helpers.sh

nfs-up:
	kubectl --namespace=rstudio apply -f ./nfs.yml
nfs-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./nfs.yml

nfs-ip-fix:
	./ip_hack.sh

nfs-pv-up:
	echo 'be sure the IP is set properly in ./pv.yml !!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	kubectl --namespace=rstudio apply -f ./pv.yml
nfs-pv-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./pv.yml


nfs-launcher-mounts:
	kubectl create configmap --namespace=rstudio launcher-mounts --from-file ./cluster/launcher-rsp-ldap/launcher-mounts

launcher-keys:
	kubectl create configmap --namespace=rstudio launcher-pem --from-file ./cluster/launcher.pem && \
	kubectl create configmap --namespace=rstudio launcher-pub --from-file ./cluster/launcher.pub

launcher-ldap-config:
	kubectl create configmap --namespace=rstudio launcher-config \
		--from-file ./cluster/launcher.pem \
		--from-file ./cluster/launcher.pub \
		--from-file ./cluster/launcher-rsp-ldap/launcher-mounts \
		--from-file ./cluster/launcher-ldap/launcher.kubernetes.profiles.conf \
		--from-file ./cluster/launcher-ldap/launcher.conf \
		--from-file ./cluster/launcher-rsp-ldap/rserver.conf

launcher-ldap-config-down:
	kubectl delete --namespace=rstudio --ignore-not-found=true configmap launcher-config

launcher-prof-conf:
	kubectl create configmap --namespace=rstudio launcher-prof-conf --from-file ./cluster/launcher-ldap/launcher.kubernetes.profiles.conf
launcher-prof-conf-down:
	kubectl delete configmap --namespace=rstudio launcher-prof-conf

launcher-conf:
	kubectl create configmap --namespace=rstudio launcher-conf --from-file ./cluster/launcher-ldap/launcher.kubernetes.conf
launcher-conf-down:
	kubectl delete configmap --namespace=rstudio launcher-conf

#launcher-conf:
#	kubectl create configmap --namespace=rstudio launcher-conf --from-file ./cluster/launcher-ldap/launcher.conf
#launcher-conf-down:
#	kubectl delete configmap --namespace=rstudio launcher-conf

secret-rsp:
	kubectl --namespace=rstudio create secret generic license --from-file=./rsp

secret-rsp-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true secret license

ldap-up:
	kubectl --namespace=rstudio apply -f ./ldap.yml
ldap-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./ldap.yml

launcher-up:
	echo 'be sure the IP is set properly in ./cluster/launcher-rsp/launcher-mounts!!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	kubectl --namespace=rstudio apply -f ./launcher.yml
launcher-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./launcher.yml

launcher-ldap-up:
	echo 'be sure the IP is set properly in ./cluster/launcher-rsp/launcher-mounts!!' && \
	echo 'you can get it with `kubectl --namespace=rstudio describe service nfs01`' && \
	kubectl --namespace=rstudio apply -f ./launcher-ldap.yml
launcher-ldap-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./launcher-ldap.yml


rsp-ldap-up:
	kubectl --namespace=rstudio apply -f ./rsp-ldap.yml
rsp-ldap-down:
	kubectl --namespace=rstudio delete --ignore-not-found=true -f ./rsp-ldap.yml
