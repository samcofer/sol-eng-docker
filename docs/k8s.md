# Kubernetes

## Getting Started

You will need:
- a working Kubernetes installation with `kubectl` on your `PATH`
- `jq`
- `curl`
- `docker`
- `make`.
- `helm` (version 3+)
    - `helm-s3` plugin (how to install below)

You will also need AWS access to the `sol-eng-helm-charts` bucket. Be sure you
have programmatic AWS access set up for your username, and then check access
with

```
aws s3 ls s3://sol-eng-helm-charts
```

The easiest way to set up Kubernetes on Mac is with the Kubernetes installation
that is bundled with Docker (see more below).  Then do `brew install jq` and
`brew install helm` too!

You will also need a license that is used below. For more
tips on getting started, check out the section below on setup.

```
# install the helm-s3 plugin
helm plugin install https://github.com/hypnoglow/helm-s3.git

# add the soleng repo
helm repo add soleng s3://sol-eng-helm-charts/

# create a bare-bones RSP instance with Kubernetes!
make k8s-rsp-up
make k8s-rsp-down
```

## Kerberos

Running Kerberos in a Kubernetes cluster takes a few more steps

!! IMPORTANT DISCLAIMER !!

> Some of these images are built locally and not pushed to a repository.  As a
> result, it is expected that you will build and use them _on the same node_.
> I.e. Docker for Mac. Using these images will not work on an EKS cluster, for
> instance.

```
# build requisite images
make kerb-server-build
make kerb-rsp-build
make kerb-ssh-build

make k8s-kerb-server-up
make k8s-kerb-ssh-up
make k8s-kerb-rsp-up

# to delete
make k8s-kerb-rsp-down k8s-kerb-ssh-down k8s-kerb-server-down
```

## Helpful Kubernetes Tips

To reload configuration in a pod:
```
kubectl delete pod <<pod name >>
# example
kubectl delete pod rsp-123-abc
```

To look at a service in your local browser
```
kubectl port-forward <<pod name>> <<local port>>:<<remote port>>
# example (go to localhost:8888 in your browser)
kubectl port-forward rsp-123-abc 8888:8787
```

To see pod details:
```
kubectl get pods
kubectl get pod  <<pod name>> -o yaml
kubectl describe pod <<pod name>>
```

To get pod logs:
```
kubectl logs <<pod name>>
```

## Example Commands (OLD)

```
# create rstudio namespace and LDAP seed users
make k8s-setup

# set up nfs
make k8s-nfs-up

# ip hack...
make k8s-nfs-ip-fix

# stand up pv
make k8s-nfs-pv-up

# stand up ldap
make k8s-ldap-up

# create secret for licensing rsp
echo 'MY_LICENSE_KEY' > k8s/rsp
make k8s-secret-rsp

# stand up rsp
make k8s-rsp-ldap-up

# stand up launcher
make k8s-launcher-ldap-up
```

If you are naive and trusting of our rigor, you can try the very optimistic "do it all at once"
```
echo 'MY_LICENSE_KEY' > k8s/rsp
make k8s-ldap-all-up
```

## More Setup

### Docker Kubernetes for Mac

There is an [analog for
Windows](https://blog.docker.com/2018/01/docker-windows-desktop-now-kubernetes/)
that we have not tested yet.

In any case, [this
tutorial](https://rominirani.com/tutorial-getting-started-with-kubernetes-with-docker-on-mac-7f58467203fd)
has a few (out-of-date) recommendations that are helpful!

### Using GKE

All you have to do to use Google Cloud is [change your `kubectl`
context](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)!!

### The Kubernetes Dashboard

When you're done, make sure to install and port-forward the Kubernetes
dashboard, which is helpful for debugging (even though the logging is a little
weird).

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

# manual port-forwarding
kubectl --namespace=kube-system get pods
kubectl --namespace=kube-system port-forward <paste kubernetes-dashboard-pod-name here> 8443:8443

# magical automatic-ness with a horrible URL
kubectl proxy

# then go to the following in your browser:
# https://<master-ip>:<apiserver-port>/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

[More on the magical automatic-ness](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

## Setup tweaks that prevent automation

- [x] Need to figure out how to put secrets into the container without hard-coding the license...
- [x] Need to consolidate commands to set up k8s (user profiles, namespace, etc.)
- [x] Setup LDAP server in k8s
- [x] Use LDAP to provision the users / home directories / etc. as needed
- [x] User UIDs need to be mapped... we should probably specify these in our docker images for consistency
- [x] The NFS server needs home directories
- [x] The NFS server needs to be mounted at creation onto the RSP server
- [x] The NFS server needs to support multiple exports (how does that work with NFS v4?)
- [x] The job launcher needs to be started... (can that happen before RSP is started?)
- [x] Maybe split the job launcher into its own service?
- [ ] Need to figure out health checks to k8s stuff, so we can keep executing commands without `sleep`
- [ ] Need to track through [this issue](https://github.com/kubernetes/kubernetes/issues/44528) 
(and related links) so that we can get service names working and not use our clusterIP hack...
- [ ] Need to auto-forward port 8787 so that it is accessible, we can interact with RSP, etc. (similarly for the dashboard)
- [ ] Need to get RSP version and RSP session version in sync
    - [Relevant (and depressing) approach](https://github.com/kubernetes/kubernetes/issues/52787#issuecomment-369645645)
- [x] Ensure the appropriate service account is [being
  used](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
with `spec.serviceAccountName`?

## To Do

### Cleanup

- [ ] why doesn't the license activation deactivate on container teardown? :(
- [ ] is the s6 ugliness worth it? figure out how to get logging...
- [x] pull out the launcher bits from RSP... and the RSP bits from launcher!
- [x] need to set up a persistent node location for the home directories...
- [x] need to implement `sssd` in the `S6` init script...
- [x] need to figure out why the home directory is not writable by default...
- [x] need to switch home directories to `/home/user`
- [ ] need to make the "clean up" do a better job of handling partial
  deployments. at present, it bombs when it fails at deleting something that
  does not exist... is there a cleaner way to do cleanup or say "do not error"?
- [ ] need to make the IP address dependent files mount into the images...
- [ ] need to decrease image size
- [ ] need to save / push the images somewhere re-usable?
- [ ] need to make all config files mounted into the image... easier to iterate on!

### Product

- [ ] rebuild the RSP pod while sessions are in flight... sessions get
  disconnected / picked up / but then a 401 error...
    - Need to make the .pem .pub files persistent
    - Turns out this is a little trickier than I thought... Need to do some
      sleuthing on when launcher/rsp can communicate and when they cannot
- [x] separate RSP / launcher... then the homepage does not load at all if
  launcher is not working (reported. waits 2 minutes for timeout)
- [x] rstudio-launcher > somefile 2>&1 gives no output... and nothing in the
  file... (same problem as RSP... come on 1.3!)
- [ ] how restrictive is the `launcher.conf` URL? (Pretty restrictive... cannot
  use a domain name)
- [x] does launcher _actually_ need the `job-launcher` role? I'm not using
  it...? NO! It doesn't!
- [x] does launcher need the home directory...? (seems like it)... YES
- [x] is there a way to provision users on the launcher server... RSP gets it
  from PAM logon...
    - UID / GID _has_ to be the same, or problems!
    - This can be done via LDAP / SSSD! Too cool! The `/etc/nsswitch.conf` file
      takes care of it. Test with `getent passwd username`
- [x] Does the launcher need `/home` mounted? It does not!
- [x] Does the launcher need licensing? Nope!
- [x] Does launcher need privileged? No!
- [ ] Is there a way to use a persistentVolumeClaim for the launcher sessions?
- [ ] Does RSP need R installed when the launcher is being used? Hopefully not!
- [ ] Changing the image for an existing session is possible, but throws an
  ugly / indecipherable error
- [ ] Some sessions start as disconnected... is this a product of my
  `supervisor.sh`?
- [ ] Configuring the session stuff in `rserver.conf` (i.e.
  `rsession-exec-supervisor`) is a bit weird...
- [ ] System changes to the container are not supported... we throw away the container
  whenever the session suspends. If you made changes, those will be discarded and you will
  start again from a different image
- [ ] When a config error in `launcher.kubernetes.conf`, nothing useful is logged as an error...
  maybe part of the problem here is that I am in docker, where all logs are useless?
- [ ] Smarter package installation that is more linux-aware... different distributions will install
  to the same location = package nightmare :scream: Yuck! Probably only a single distro for now
- [ ] Let the IDE sit for a while... longer than some timeout window, then hit the blue home button
  redirects to the wrong location?

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

- [debug a stopped container](https://stackoverflow.com/questions/20813486/exploring-docker-containers-file-system)
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

## Docker for Mac Debugging

I encountered a strange issue where Docker for Mac Kubernetes would not start. This is a fairly common problem, apparently:

- [On Mac](https://github.com/docker/for-mac/issues/2536)
- [More Mac](https://github.com/docker/for-mac/issues/1348)
- [And More](https://github.com/docker/for-mac/issues/1025)
- [Really, more?](https://github.com/docker/for-mac/issues/2985)
- [Literally. Everyone is having this problem](https://github.com/docker/for-mac/issues/2720)
- [On Windows](https://github.com/docker/for-win/issues/1649)

Some really useful debugging practices:

- [Use the Console](https://blog.couchbase.com/docker-daemon-log-mac/)

And some therapeutic but fruitless ones:

- Delete `~/.kube`
- Delete `~/.docker`
- Reset to Factory Settings
- Nuke the entire installation
- Delete the `Docker.qcow2` file that has been eating my hard drive

And the solution:

- Change my DNS nameserver to 8.8.8.8 got me a partial fix, but then I could not resolve docker-for-desktop.localdomain.
- Fiddling with my router settings to enable MultiCast DNS and mDHCP... or something... it fixed the issue. Weird
- Keep an eye on the Console logs! Wacky stuff going on in there!

## Nightmares in NFS Land

Unfortunately, I have travelled down a deep dark hole related to NFS. My aim: NFS server in a docker container. A handful of people say it is possible. 
I have successfully achieved read and modify files, but _create file_ fails for some crazy reason.

**UPDATE:** This turns out to have been a "Mac" thing. Apparently `no_root_squash` is not understood on Mac... so don't use it in your NFS config!

Debugging Overview:
- Try different protocols (`-t nfs`, `-t nfs4`)
- Try different options (`-o vers=4`, `-o nolock`)
- Try different paths (`nfs01:/`, `nfs01:/actual/path`, `nfs01:/share`)
- Permissions / ownership / UID mapping can be weird... (`ls -lha` and `id myuser` are your friends)
- **SET PRIVILEGED=TRUE in your K8S config!!!!**
    - I lost several hours of my life to this nonsense. Please remember that the client needs `privileged: true` to mount NFS

Wins:
- Use the ClusterIP of the node (`kubectl describe services --namespace=rstudio nfs01`)
- **----->>>** [Read about the problem of resolving service names. This is
  promising for the future!
](https://github.com/kubernetes/kubernetes/issues/44528)
- [Related service publishing issue to the host](https://github.com/docker/for-mac/issues/2445) [another](https://github.com/docker/for-mac/issues/171)

- [Persistent Volumes on K8s](https://medium.com/platformer-blog/nfs-persistent-volumes-with-kubernetes-a-case-study-ce1ed6e2c266)
- [Another nfs k8s issue](https://github.com/kubernetes/kubernetes/issues/44377)
- [Networking and URL resolution](https://blog.heptio.com/configuring-your-linux-host-to-resolve-a-local-kubernetes-clusters-service-urls-a8c7bdb212a7)

- [Avoid no_root_squash](https://www.tecmint.com/setting-up-nfs-server-with-kerberos-based-authentication/)
- [Explaining no_root_squash](https://bencane.com/2012/11/23/nfs-setting-up-a-basic-nfs-file-system-share/)
- [Explaining user mapping](https://unix.stackexchange.com/questions/9442/why-is-file-ownership-inconsistent-between-two-systems-mounting-the-same-nfs-sha)

- [NFS and Persistent Volumes on AWS](https://docs.giantswarm.io/guides/using-persistent-volumes-on-aws/)
    - [aws storage classes](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html)
    - [explanation](https://www.jeffgeerling.com/blog/2019/expanding-k8s-pvs-eks-on-aws)

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
- [more volume stuff](https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-volumes-example-nfs-persistent-volume.html)

- [minikube nfs issues](https://github.com/kubernetes/minikube/issues/2218)

- [nfsv4 on k8s](https://www.reddit.com/r/homelab/comments/7x3xoq/nfs_4_on_kubernetes/)

- [helm stuff](https://github.com/helm/helm)

- [k8s logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

Ingress:
- [traefik docs](https://docs.traefik.io/user-guide/kubernetes/)
     - [traefik web ui](https://github.com/containous/traefik#web-ui)
     - [traefik blog post](https://capgemini.github.io/kubernetes/kube-traefik/)
- [Google Cloud network
  overview](https://cloud.google.com/kubernetes-engine/docs/concepts/network-overview)
( [and helpful
section](https://cloud.google.com/kubernetes-engine/docs/concepts/network-overview#services)
)
- [Google Cloud Load Balancing](https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer)
- [Kubernetes Service Types Overview](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)
- [Kubernetes Ingress docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress)
    - [more nginx ingress](https://cloud.google.com/community/tutorials/nginx-ingress-gke)

Startup:
- [Mount in an entrypoint](https://etoews.github.io/blog/2017/07/29/inject-an-executable-script-into-a-container-in-kubernetes/)

TODO:
- Kubernetes _NEEDS_ better docs on volumes, specifically DefaultMode
    - Not sure if this is needed, but [converting octal to decimal](https://coolconversion.com/math/binary-octal-hexa-decimal/Convert_decimal_number_384_in_octal_)
