# Kubernetes

## Debugging Tips

```
# get pods in a namespace
kubectl get pods --namespace=rstudio

# get a specific pod
kubectl get pods --namespace specific-pod-name -o yaml | less

# get a specific pod's docker id to use in docker logs
kubectl get pods --namespace=rstudio specific-pod-name -o json | jq -r '.status.containerStatuses[0].containerID' | sed 's/docker:\/\///'

# port-forward
kubectl port-forward --namespace=rstudio specific-pod-name host-port:guest-port

# get interactive shell (only dealing with single-container pods)
kubectl exec -it --namespace=rstudio specific-pod-name -- /bin/bash
```

## Resources

### Gold

- [K8s for compose/swarm users](https://hackernoon.com/a-kubernetes-guide-for-docker-swarm-users-c14c8aa266cc)
- [Using the API from inside K8s](https://medium.com/@pczarkowski/the-kubernetes-api-call-is-coming-from-inside-the-cluster-f1a115bd2066)
- [How to get Services to interact](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)
- [More pod conversation topics](https://www.quora.com/How-do-I-establish-communication-between-pods-in-Kubernetes)


### Formal Docs on YAML Syntax

- [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/)
- [Configure a pod container](https://kubernetes.io/docs/tasks/configure-pod-container/)
- [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)
- [More Auth?](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

### Random Topics

- [Get an interactive shell in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/)
- [Compose and Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/)
- [Define env vars](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/)
- [Docker stack deploy](https://docs.docker.com/engine/reference/commandline/stack_deploy/)

## Nightmares in NFS Land

Unfortunately, I have travelled down a deep dark hole related to NFS. My aim: NFS server in a docker container. A handful of people say it is possible. 
I have successfully achieved read and modify files, but _create file_ fails for some crazy reason.

Debugging Overview:
- Try different protocols (`-t nfs`, `-t nfs4`)
- Try different options (`-o vers=4`, `-o nolock`)
- Try different paths (`nfs01:/`, `nfs01:/actual/path`, `nfs01:/share`)
- Permissions / ownership / UID mapping can be weird... (`ls -lha` and `id myuser` are your friends)

Links:
- [general troubleshooting](https://wiki.archlinux.org/index.php/NFS/Troubleshooting)
- [nfs overview](https://www.tecmint.com/how-to-setup-nfs-server-in-linux/)
- [nfs on mac](https://www.cyberciti.biz/faq/apple-mac-osx-nfs-mount-command-tutorial/)
- [random debugging forum](https://www.linuxquestions.org/questions/linux-software-2/mount-nfs-input-output-error-578484/)
- [random debugging forum 2.0](https://www.linuxquestions.org/questions/linux-software-2/nfs-and-file-permissions-problem-4175438474/)
- [unrelated write access issue](https://community.emc.com/thread/126846?start=0&tstart=0)

- [docker nfs server](https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/)
- [docker nfs server git repo](https://github.com/sjiveson/nfs-server-alpine)
- [docker nfs server / client](https://github.com/cpuguy83/docker-nfs-server)
- [related blog post](https://container42.com/2014/03/29/docker-quicktip-4-remote-volumes/)

- [how to use strace](https://www.tecmint.com/strace-commands-for-troubleshooting-and-debugging-linux/)

