# Kubernetes

This module will walk you through some basics for getting started with
Kubernetes, so we can use it for further product exploration / playing.

## Getting started with Kubernetes!

First, let's do some environment setup:

- Install `kubectl`
- Install Docker Desktop. Enable Kubernetes (on Mac/Windows). This will give you a local kubernetes cluster
    - On linux, you might look at installing `minikube`
- Set your `context` to your local kubernetes cluster:
```
kubectl config get-contexts
kubectl config use-context docker-desktop
kubectl config current-context
```

Now we are ready to have some fun!

## A simple example

> One simple way of thinking about Kubernetes is YAML that defines deployments of docker (or other) containers

Let's create a simple deployment. 
