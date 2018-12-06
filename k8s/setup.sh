# build rstudio namespace
ns=`kubectl get namespace rstudio`
res=$?
if [ $res -gt 0 ]; then
  echo 'rstudio namespace does not exist'
  echo 'creating rstudio namespace'
  kubectl create namespace rstudio
fi

# not needed...
# kubectl create serviceaccount --namespace=rstudio job-launcher
# kubectl create rolebinding job-launcher-admin --clusterrole=cluster-admin --user=job-launcher --namespace=rstudio

# build configmap for LDAP seed users
ldap_users=`kubectl get configmap --namespace=rstudio ldap-users`
res=$?
if [ $res -gt 0 ]; then
  echo 'the ldap-users configmap does not exist in the rstudio namespace'
  echo 'creating configmap ldap-users'
  kubectl create configmap --namespace=rstudio ldap-users --from-file ./cluster/users.ldif
fi
