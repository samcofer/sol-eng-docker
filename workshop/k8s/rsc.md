# Installing RStudio Connect on Kubernetes

To get started, check out [../install.md](./install.md) and [../setup.md](./setup.md).

If you need an introduction to `helm`, there is a decent introduction [here](./helm.md)

Now we are going to install RStudio Connect!

On our training cluster, we already have:

- Ingress taken care of
- Storage taken care of (using the `efs-client` storage class).

As a result, we will do the following to install:

- Install postgres
- Install and configure Connect
- Add an ingress to access the service (make sure to suffix your selected name
  with `.training.soleng.rstudioservices.com`)
- (Make sure to add a middleware!)
- Deploy an application
- Note some points on how to get information about the application, where it is running, etc.

## Let's go!!

[Docs are hosted here](https://docs.rstudio.com/helm/rstudio-connect/kubernetes-howto/)

([with sources here](https://github.com/rstudio/connect-kubernetes-docs))

## The line between helm, docker, kubernetes, and our product

## What if you wanted to configure authentication?

## What if you wanted to configure email?

## Differences between classic Connect and launcher Connect
