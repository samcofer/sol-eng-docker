# Kubernetes

## Getting Started

```
# create rstudio namespace and LDAP seed users
make k8s-setup

# set up nfs
make k8s-nfs-up

# ip hack...
make k8s-nfs-fix-ip

# stand up ldap
make k8s-ldap-up

# create secret for licensing rsp
echo 'MY_LICENSE_KEY' > k8s/rsp
make k8s-secret-rsp

# stand up launcher
make k8s-launcher-ldap-up

# stand up rsp
make k8s-launcher-rsp-ldap-up
```

## Setup tweaks that prevent automation

- [x] Need to figure out how to put secrets into the container without hard-coding the license...
- [x] Need to consolidate commands to set up k8s (user profiles, namespace, etc.)
- [x] Setup LDAP server in k8s
- [ ] Use LDAP to provision the users / home directories / etc. as needed
- [ ] User UIDs need to be mapped... we should probably specify these in our docker images for consistency
- [ ] The NFS server needs home directories
- [x] The NFS server needs to be mounted at creation onto the RSP server
- [x] The NFS server needs to support multiple exports (how does that work with NFS v4?)
- [x] The job launcher needs to be started... (can that happen before RSP is started?)
- [x] Maybe split the job launcher into its own service?
- [ ] Need to figure out health checks to k8s stuff, so we can keep executing commands without `sleep`
- [ ] Need to track through [this issue](https://github.com/kubernetes/kubernetes/issues/44528) 
(and related links) so that we can get service names working and not use our clusterIP hack...
- [ ] Need to auto-forward port 8787 so that it is accessible, we can interact with RSP, etc. (similarly for the dashboard)
- [ ] Need to get RSP version and RSP session version in sync
- [x] Ensure the appropriate service account is [being
  used](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
with `spec.serviceAccountName`?

## To Do

### Cleanup

- why doesn't the license activation deactivate on container teardown? :(
- pull out the launcher bits from RSP... and the RSP bits from launcher!
- is the s6 ugliness worth it?
- need to set up a persistent node location for the home directories...
- what sort of weirdness is happening with home directories being nonstandard...? clean this up in ldap!
    - the user that is provisioned in the session container probably has a default home directory...
    - yes, home directory does not seem to be mapped from the launcher server to the session
    - `/home/user` works fine, but `/home/users/user` does not (even when set correctly on rsp / launcher)
- need to implement `sssd` in the `S6` init script...
- need to figure out why the home directory is not writable by default...
- need to switch home directories to `/home/user`

### Product

- rebuild the RSP pod while sessions are in flight... sessions get disconnected / picked up / but then a 401 error...
- separate RSP / launcher... then the homepage does not load at all if launcher is not working 
- rstudio-launcher > somefile 2>&1 gives no output... and nothing in the file...
- how restrictive is the `launcher.conf` URL?
- does launcher _actually_ need the `job-launcher` role? I'm not using it...?
- does launcher need the home directory...? (seems like it)
- is there a way to provision users on the launcher server... RSP gets it from PAM logon...
    - UID / GID _has_ to be the same, or problems!

## Debugging Tips

```
# ensure your kubectl context is set properly
kubectl config current-context

# on mac
kubectl config use-context docker-for-desktop

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

# figure out the clusterIP for a service (nfs01)
kubectl describe services --namespace=rstudio nfs01

# create secret secret-name/secret-key/secret-value
echo 'secret-value' > secret-key.txt
kubectl create secret --namespace=rstudio generic secret-name --from-file=./secret-key.txt

# get secrets
kubectl get secrets
kubectl describe secrets/secret-name

# get secret details
kubectl get secret secret-name -o yaml
```

## Resources

### Gold

- [How to use secrets](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/)
- [Kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [K8s for compose/swarm users](https://hackernoon.com/a-kubernetes-guide-for-docker-swarm-users-c14c8aa266cc)
- [Using the API from inside K8s](https://medium.com/@pczarkowski/the-kubernetes-api-call-is-coming-from-inside-the-cluster-f1a115bd2066)
- [How to get Services to interact](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)
- [More pod conversation topics](https://www.quora.com/How-do-I-establish-communication-between-pods-in-Kubernetes)
- [k8s `command` / `args` vs Docker Entrypoint / Cmd](https://stackoverflow.com/questions/44316361/difference-between-docker-entrypoint-and-kubernetes-container-spec-command)

### Formal Docs

- [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/)
- [ConfigMap (i.e. mount a file into a pod)](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
    - [And an example](https://stackoverflow.com/questions/33415913/whats-the-best-way-to-share-mount-one-file-into-a-pod)
- [Configure a pod container](https://kubernetes.io/docs/tasks/configure-pod-container/)
- [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)
- [More Auth?](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)

### Random Topics

- [Debugging DNS resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
- [Custom DNS stuff](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
- [More DNS for services/pods/etc.](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Pods and Volume Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/)
- [Get an interactive shell in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/)
- [Compose and Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/)
- [Define env vars](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/)
- [Docker stack deploy](https://docs.docker.com/engine/reference/commandline/stack_deploy/)
- [how to use strace](https://www.tecmint.com/strace-commands-for-troubleshooting-and-debugging-linux/)

## Nightmares in NFS Land

Unfortunately, I have travelled down a deep dark hole related to NFS. My aim: NFS server in a docker container. A handful of people say it is possible. 
I have successfully achieved read and modify files, but _create file_ fails for some crazy reason.

**UPDATE:** This turns out to have been a "Mac" thing. Apparently `no_root_squash` is not understood on Mac... so don't use it in your NFS config!

Debugging Overview:
- Try different protocols (`-t nfs`, `-t nfs4`)
- Try different options (`-o vers=4`, `-o nolock`)
- Try different paths (`nfs01:/`, `nfs01:/actual/path`, `nfs01:/share`)
- Permissions / ownership / UID mapping can be weird... (`ls -lha` and `id myuser` are your friends)

Wins:
- Use the ClusterIP of the node (`kubectl describe services --namespace=rstudio nfs01`)
- **----->>>** [Read about the problem of resolving service names. This is
  promising for the future!
](https://github.com/kubernetes/kubernetes/issues/44528)

- [Persistent Volumes on K8s](https://medium.com/platformer-blog/nfs-persistent-volumes-with-kubernetes-a-case-study-ce1ed6e2c266)
- [Another nfs k8s issue](https://github.com/kubernetes/kubernetes/issues/44377)
- [Networking and URL resolution](https://blog.heptio.com/configuring-your-linux-host-to-resolve-a-local-kubernetes-clusters-service-urls-a8c7bdb212a7)

- [Avoid no_root_squash](https://www.tecmint.com/setting-up-nfs-server-with-kerberos-based-authentication/)
- [Explaining no_root_squash](https://bencane.com/2012/11/23/nfs-setting-up-a-basic-nfs-file-system-share/)
- [Explaining user mapping](https://unix.stackexchange.com/questions/9442/why-is-file-ownership-inconsistent-between-two-systems-mounting-the-same-nfs-sha)

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

- [minikube nfs issues](https://github.com/kubernetes/minikube/issues/2218)

- [nfsv4 on k8s](https://www.reddit.com/r/homelab/comments/7x3xoq/nfs_4_on_kubernetes/)
