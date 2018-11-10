kubectl create namespace rstudio
kubectl create serviceaccount --namespace=rstudio job-launcher
kubectl create rolebinding job-launcher-admin --clusterrole=cluster-admin --user=job-launcher --namespace=rstudio
