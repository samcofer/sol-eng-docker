# RStudio Workbench on Kubernetes

## Getting Started

### Installation

In order to install the Kubernetes dependencies for this workshop, visit the [install docs, here](../k8s/install.md).

### Setup

If this workshop is running internally at present, there should be
an [internal cluster](../k8s/setup.md#remote-setup-workshop) to setup. Otherwise, reach out to `#auth-workshop` or try
another [setup method](../k8s/setup.md).

### License

For this workshop, you will need a valid RStudio Workbench license key exported as the `RSW_LICENSE` environment variable.

i.e. `export RSW_LICENSE=some-license-key`

Oftentimes, I will do this in `~/.bashrc` or `~/.zshrc` so that I have it available in every shell. Reach out
to `#support` or licenses@rstudio.com if you need a license key.

## Intro to Kubernetes

In the interest of time, we are going to [skip the first introduction to Kubernetes](../k8s.md). However, if you are
unfamiliar with Kubernetes or have not used it before, there are some useful tidbits in the hello-world example here
that you may want to revisit!

## Part 1 - Hello Workbench!

**Goal**: Run a simple RStudio Workbench container with a basic YAML deployment using only `kubectl`

We will walk through the guide in the [`workshop/k8s/rsw` file](../k8s/rsw.md).

## Part 2 - Helm Introduction

**Goal**: Introduce `helm` and deploy a hello world application. Understand how/why `helm` is a useful tool for
administrators

Docs for this section are in [`workshop/k8s/helm`](../k8s/helm.md)

## Part 3 - Helm Workbench

**Goal**: Use `helm` to deploy a simple instance of RStudio Workbench. Notice that this is much "easier," more
configurable, and more complete than our previous example. (The cost is complexity)

## Part 4 - Helm HA Workbench

**Goal**: Deploy _all the things_ with `helm`. High Availability with Postgres, Shared Storage, Load Balancing, etc.
