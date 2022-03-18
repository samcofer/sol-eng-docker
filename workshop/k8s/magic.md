# What is this Magic?

You know what they say: A magician never tells.

Well I'm not a magician, so I can tell you what's going on.

## "Admin" Magic

A lot of these Kubernetes tutorials presume that you have a "nicely configured" Kubernetes cluster.
Kubernetes Administrators make this possible, and in the ideal world, everyone would have such a cluster. In the real world,
peoples' experiences vary. For the training workshop, we have provisioned a Kubernetes cluster with:

- A "nice" storage class for our professional products
    - A "storage class" is a "way of providing storage"
    - Our Pro Products (mostly) need "Read Write Many" storage, which is less common on Kubernetes
    - By providing a useful storage class, admins can ensure that users are able to deploy their apps without custom work
- An "ingress controller"
    - "Getting network traffic into the Kubernetes cluster" is called "Ingress"
    - An "ingress controller" knows how to turn "Ingress" resources into routing (and is usually just a proxy. Popular
      ingress controllers include `nginx` and `traefik`)
- A certificate
    - There are lots of snazzy ways to provide certificates on a Kubernetes cluster (check
      out [cert-manager](https://cert-manager.io/) if interested)
    - We use an ACM wildcard certificate on an AWS load balancer to ensure that a certain subdomain gets TLS enabled!
- A DNS Controller
    - `external-dns` knows how to take Ingress objects, annotations, etc. and turn them into DNS records for various DNS registrars
    - Since we are on AWS, `Route 53` is our registrar. `external-dns` has been given access to manage domain names for us! 
- Access with a KubeConfig file
    - This is a naive / simple  solution to access controls
    - It works nicely for workshops... not so nicely for access curation, secret management, or organizational security 😅
    - However, it avoids some of the pain of setting up SSO with AWS, cross-account access, etc.
    - To do this, we use a [hacky helm chart](https://github.com/colearendt/helm/tree/main/charts/training-ns), what else?

## What else?

Most everything else is just Kubernetes! It feels like magic to me too. Things may vary for you based on which
Kubernetes provider you are using and how much "infrastructure as code" you are using (i.e. it is possible to create DNS
records manually).

For instance, Docker for Desktop, `k3s`, and others have some niceties that they occasionally set up by default, and the
cloud providers have lots of built-in functionality, but your experience across these providers will vary!
