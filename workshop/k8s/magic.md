# What is this Magic?

You know what they say: A magician never tells.

Well I'm not a magician, so I can tell you what's going on.

## "Admin" Magic

A lot of these Kubernetes tutorials presume that you have a "nicely configured" Kubernetes cluster.
Kubernetes Administrators make this possible, and in the ideal world, everyone would have such a cluster. In the real world,
peoples' experiences vary. For the training workshop, we have provisioned a Kubernetes cluster with:

- A "nice" storage class for our professional products

## What else?

Most everything else is just Kubernetes! It feels like magic to me too. Things may vary for you based on which
Kubernetes provider you are using and how much "infrastructure as code" you are using (i.e. it is possible to create DNS
records manually).

For instance, Docker for Desktop, `k3s`, and others have some niceties that they occasionally set up by default, and the
cloud providers have lots of built-in functionality, but your experience across these providers will vary!
