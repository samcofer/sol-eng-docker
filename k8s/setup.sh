# build rstudio namespace
ns=`kubectl get namespace rstudio`
res=$?
if [ $res -gt 0 ]; then
  echo 'rstudio namespace does not exist'
  echo 'creating rstudio namespace'
  kubectl create namespace rstudio
fi

# not needed locally... but needed in GKE
kubectl create serviceaccount --namespace=rstudio job-launcher

# wacky incantation that works
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin --user $(gcloud config get-value account)
kubectl create clusterrole job-launcher-api \
   --verb=impersonate \
   --resource=users,groups,serviceaccounts
kubectl create rolebinding job-launcher-impersonation \
   --clusterrole=job-launcher-api \
   --group=system:serviceaccounts:rstudio \
   --namespace=rstudio
kubectl create rolebinding job-launcher-admin \
   --clusterrole=cluster-admin \
   --group=system:serviceaccounts:rstudio \
   --namespace=rstudio

# build configmap for LDAP seed users
ldap_users=`kubectl get configmap --namespace=rstudio ldap-users`
res=$?
if [ $res -gt 0 ]; then
  echo 'the ldap-users configmap does not exist in the rstudio namespace'
  echo 'creating configmap ldap-users'
  kubectl create configmap --namespace=rstudio ldap-users --from-file ./cluster/users.ldif
fi
