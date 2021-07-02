# Kubernetes

This module will walk you through some basics for getting started with
Kubernetes, so we can use it for further product exploration / playing.

## Overview

- [docker and containers](./get_started.md)
- [Set up a lightweight dev environment](./k8s/k3d.md)
- [Kubernetes and YAML](./k8s.md#what-is-kubernetes)
- [Helm](./k8s/helm.md)
- [Using Helmfile](./k8s/helmfile.md)

## What is Kubernetes?

> One simple way of thinking about Kubernetes is YAML that defines deployments of docker (or other) containers

Kubernetes is a specification that simplifies deployment of containers across multiple hosts in particular, and
microservice architectures, in general. At its most basic, deployments to Kubernetes consist of YAML (or JSON). The
specification differs from `docker` and `docker-compose`, but the paradigm is similar.

## Getting started with Kubernetes!

First, let's do some environment setup:

- [Install `kubectl`](https://kubernetes.io/docs/tasks/tools/)
  - on Mac, TL;DR; (if using `brew`): `brew install kubectl`
- Choose either "local" or "remote" setup below

### Local Setup

- Install Docker Desktop. Enable Kubernetes (on Mac/Windows). This will give you a local kubernetes cluster
  - On linux, you might look at installing [`k3s`](./k8s/k3s.md)
    - which has less "magic" and uses less resources than `minikube`
    - Or [`k3d`](https://k3d.io) (`k3s` in docker)
  - Alternatively, `minikube`
  - `kind` is another lightweight kubernetes distribution recommended by the Kubernetes project
- Set your `context` to your local kubernetes cluster:
```bash
kubectl config get-contexts
kubectl config use-context docker-desktop
kubectl config current-context
```

### Remote Setup (workshop)

- In some internal workshops, we will provide a cluster with a `KUBECONFIG` file that you can use to connect to your own
  private / personal namespace. Reach out to `#sales-ops` or `#auth-workshop` if you have questions.
- You should have a `KUBECONFIG` file sent to you over slack. Download this file and save it in a memorable place like:
  - `~/kubeconfig-training-myname`
  - `kubeconfig-training-myname` (in the directory you are working in - the clone of this repo, for instance)
  - `~/.kube/kubeconfig-training-myname`
> NOTE: these particular configuration files are _temporary_ so do not expect them to work forever.

> NOTE: also, these values are _sensitive_. So please keep them safe!!

- We recommend editing `~/.config/git/ignore` to exclude these files from version control like so:
```bash
mkdir -p ~/.config/git/
# add this line to the file
echo 'kubeconfig-training-*' >> ~/.config/git/ignore
```

- Now set the `KUBECONFIG` environment variable to use this value

```bash
KUBECONFIG=./kubeconfig-training-myname kubectl get pods
```

- If you want to make this persistent, you can `export KUBECONFIG=/absolute/path/to/kubeconfig-training-myname`. Keep in
  mind that this will be persistent for your given shell until you modify the value or `unset KUBECONFIG`



### Remote Setup (AWS)

> NOTE: Setup will vary. Talk to someone on your team or reach out to `#sre`!

- This setup will vary by team. It is much like the previous remote setup except you add a context to your
  "default" kubeconfig file (at `~/.kube/config`)
- It requires using AWS roles, AWS assume roles, and the `aws` CLI  
- You will do something like:
```bash
AWS_DEFAULT_REGION=region aws eks update-kubeconfig --name=my-kubernetes-cluster --alias=my-kubernetes-cluster
```

### Now what?

Now we are ready to have some fun!

## A simple example

> One simple way of thinking about Kubernetes is YAML that defines deployments of docker (or other) containers

Let's create a simple deployment. This is an
adapted [hello-world example](https://github.com/paulbouwer/hello-kubernetes)

```bash
# go to the simple kubernetes resource folder
cd k8s/simple
kubectl apply -f hello-world.yaml
```

Now we want to make sure it is working!

```bash
kubectl get pods
kubectl get svc
kubectl get service
kubectl logs <name_of_pod>
```

If the pod is alive, let's take a look!

```bash
# change local port with something like 8090:8080
kubectl port-forward svc/hello-kubernetes 8080:8080
```

Now go to [http://localhost:8080](http://localhost:8080) in your browser!

You should see something like:

![Hello World Image](k8s/hello-world.png)

When you are done, you can remove it from your cluster like so:

```bash
kubectl delete -f hello-world.yaml
```

### How did that work?

- `kubectl apply` is like `docker-compose up` or `docker run`
- Instead of running "locally", the deployment goes to a Kubernetes cluster
- In order to see the service locally, you need to do one of two things:
  - "Expose" it publicly via a LoadBalancer or Ingress
  - "port-forward" to your local machine. You can think of this like an SSH tunnel
  
### A few notes

Take a look at [hello-world.yaml](../k8s/simple/hello-world.yaml)

- Notice Service "type" `NodePort`. This gives the service a dedicated port
  - You _can_ specify which port, but that is usually overkill and a pain to maintain
- Service "type" `LoadBalancer` will define a load balancer automatically for the service
  - i.e. on EKS, you can automatically provision an ALB
  - This works nicely on [`k3s`](./k8s/k3s.md), but is often overkill (ALB per service? No thanks)
  - Instead, we will show you how defining an "Ingress" service gives you more control!
- It is a best practice to define service ports that are "standard" for the protocol
  - I.e. 80 instead of 3939, etc.
  - Containers listen on ports that are standard for the service (i.e. 3939 for Connect)
  - The service can map to a standardized port so generic Kubernetes routing can be agnostic to specific app
    configuration

## Interactive Shell

Let's try another simple example to see more about how you can debug containers.

In the same `k8s/simple` directory, run:
```bash
kubectl apply -f busybox.yaml
```

This container writes its hostname and time periodically to /tmp/index.html

To see this in action, let's shell into the container

```bash
kubectl exec -it <name_of_pod> -- sh
```

And cat the file:
```bash
cat /tmp/index.html
```

Over time you will see that it continually updates this file every 10 seconds or so.

To remove:

```bash
kubectl delete -f busybox.yaml
```

### More Notes

Take a look [busybox.yaml](../k8s/simple/busybox.yaml)

- In docker, you have the following types of configuration:
  - `ENTRYPOINT`: The "base command" always executed by the container
  - `COMMAND`/`CMD`: The "arguments" passed to the entrypoint executable / script
  
- In Kubernetes, this paradigm changes to a better-named convention:
  - `command`: Analogous to `ENTRYPOINT`. The "command" always executed by the contanier
  - `args`: Analogous to `COMMAND`. The "args" passed to the "command"

## Get Started with RStudio!!

Ok, now we need to deploy a pro product! Let's start with the IDE!

First, we need a license! Ensure you have the environment variable `RSP_LICENSE`
exported with a real RStudio license

```bash
export RSP_LICENSE=xxxx
```

Now we will store this license on the Kubernetes cluster, where it will be accessible
to the RSP service that we deploy. Kubernetes stores such things as **secrets**

```bash
kubectl create secret generic license --from-literal="rsp=$RSP_LICENSE"
```

From the same `k8s/simple` directory, execute the following:
```bash
kubectl apply -f rsp.yaml
```

Now we will make sure all is well with the world
```bash
kubectl get pods
kubectl logs rsp-<name of pod>
```

And port-forward the service:
```bash
kubectl port-forward svc/rsp 8787:80
```

Then log in with user:password `rstudio:rstudio` and look at the output of `system('hostname')`.
That's the name of your pod!! Well done!

```r
system("hostname")
# rsp-78f9f9b56d-pqsvm
```

Again, to remove:
```bash
kubectl delete -f rsp.yaml
```

### New Concepts

Take a look at [rsp.yaml](../k8s/simple/rsp.yaml)

- Notice how we mounted the secret into the container as an environment variable
- RSP requires a "privileged" container (akin to root on the Kubernetes node). We did this with `securityContext`
- Notice the commented out `command`. This can be a hacky but useful tool if
  our products are starting up weirdly ( common for RSP due to our complicated
entrypoint script)
