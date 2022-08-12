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

We will follow a modified path below.

### [Step 1: Postgres](https://docs.rstudio.com/helm/rstudio-connect/kubernetes-howto/install/k8s_cluster_prep.html#step-2-install-postgresql-database)

### Step 2: Setup

Please keep in mind that your values will look a bit different than the docs there. Namely:

```yaml
sharedStorage:
  storageClassName: efs-client

config:
  Postgres:
    URL: # MUST USE YOUR NAMESPACE
```

In total, if you [add to the docs there](https://docs.rstudio.com/helm/rstudio-connect/kubernetes-howto/install/configure_helm_chart_values.html):

```yaml
# Controls how many instances of RStudio Connect will be created.
replicas: 1

# Configures shared storage for the RStudio Connect pod.
sharedStorage:
  create: true
  mount: true

  # The name of the PVC that will be created for Connect's data directory.
  # This PVC is also specified by `Launcher.DataDirPVCName` below.
  name: rsc-pvc

  # The storageClass to use for Connect's data directory. Must support RWX.
  storageClassName: efs-client
  requests:
    storage: 10G

# Enables building and executing content in isolated Kubernetes pods.
launcher:
  enabled: true

# The config section overwrites values in RStudio Connect's main .gcfg configuration file.
config:

  # Configures the Postgres connection for RStudio Connect.
  Database:
    Provider: "Postgres"
  Postgres:
    URL: "postgres://connect@rsc-db-postgresql.<<MY NAMESPACE>>.svc.cluster.local:5432/rsc_k8s?sslmode=disable"
    # While it is possible to set a Postgres password here in the values file, we recommend providing
    #   the password at runtime using helm install's --set argument instead
    #   (e.g. --set config.Postgres.Password=<your-postgres-database-password>)
```

### [Step 3: Install!](https://docs.rstudio.com/helm/rstudio-connect/kubernetes-howto/install/k8s_deployment.html)

To test that the instance is up / alive, you can check that it is up with:

```bash
kubectl get pods
kubectl logs deployment/rstudio-connect-prod
```

And then port-forward the service locally (to port 3939):
```bash
kubectl port-forward svc/rstudio-connect-prod 3939:80
```

Then go to http://localhost:3939 and sign up for a new account!

You can try building a piece of content from git (i.e. https://github.com/colearendt/shiny-shell), for instance, to
see if jobs are running properly! Then go back to your shell and `kubectl get pods` to see it running!

But who wants to port-forward everything!? (Nobody). How do we "take it to production"? 😄

## Let's set up ingress!

But what we really want to do is make this host available on the internet!! This is most often done with
either a load balancer or an "ingress." Load balancers cost $$$, so let's learn about ingresses!

So what you need to do first is _decide on a name_.

Then add the following to your values file! Substitute in your name for `<<NAME>>`!

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: traefik
  hosts:
    - host: <<NAME>>.training.soleng.rstudioservices.com
      paths: ["/"]
```

## The line between helm, docker, kubernetes, and our product

This takes a bit of getting used to. Hence the workshop and your increasing experience! 😄

- Helm: Responsible for templating out boilerplate and parameterizing a Kubernetes deployment. Is deterministic based on
inputs and chart / chart version. Can be exercised using `helm template`
- Docker: Responsible for creating small, reproducible, and portable "systems" that run our software. If a customer is
using our docker image and having a docker problem, we should be able to reproduce it (the image is not different). Keep in
mind that customers can build their own images (they can even name them the same as ours!!).
- Kubernetes: An orchestration engine for containers. Starts and stops containers, has many different "resource types"
and a consistent API. Uses "desired state" configuration and a resolution loop that tries to make the desired state into reality.
- Our Product: inputs are configuration and state. Outputs are effects, behaviors, and log messages. 
- The Environment: Remember that nothing is an island! Every customer runs software in some environment (Cloud, On-Premise, etc.). That goes
for kubernetes and our software alike.

Quiz:

Classify the following and where (there may be more than one!) you might start casting blame 🕵️‍♂️

- SAML Authentication fails with an error message in the logs
- RStudio Connect refuses to start because of a licensing issue. No license available!
- RStudio Connect refuses to start because of a licensing issue. Unable to activate!
- RStudio Connect will not start because there are no nodes available
- RStudio Connect cannot install a package because of a missing system dependency
- RStudio Connect cannot start because the volume mount cannot succeed

(quiz answers are hidden below 😉)

## What if you wanted to configure authentication?

You are configuring our product on how to integrate with an external system. You will use the helm chart to
configure Connect in the `config` section.

```yaml
config:
  Authentication:
    Provider: saml
  SAML:
    # ...
```

We do not need to do this for now 😄

## What if you wanted to configure email?

You are configuring our product on how to integrate with an external system. You will use the helm chart to configure
Connect in the `config` section.

i.e.
```yaml
config:
  Server:
    EmailProvider: none
```

If you want to give this a try in this environment... use these parameters:

```yaml

```

(I deployed a toy email server that you can access [here]())

BEWARE: All emails to this server are _public_!

## Differences between classic Connect and launcher Connect

- Launcher Connect: No RunAsCurrentUser
- Classic Connect: requires a "privileged" container
- Others?

## Quiz Answers

<details>
<ul>
<li>SAML authentication failure is most likely a product configuration issue. Although it could also be related to 
proxy behavior, headers, TLS termination, etc.</li>
<li>No license available means the user is not providing a license properly to the helm chart</li>
<li>Unable to activate means the product is trying to use the license, but the problem is either in the license
not having capability or activations, or the environment (i.e. outbound networking, etc.)</li>
<li>No nodes available can be either the helm chart (i.e. what resources, constraints, etc. are placed on the pod) or 
in Kubernetes itself (i.e. their cluster needs more capacity, etc.)</li>
<li>A missing system dependency suggests that the _docker image_ is having trouble in their environment. For Connect with Launcher,
your eyes should be on the _session_ image</li>
<li>Volume mount cannot succeed could be a few things. (1) the Kubernetes cluster and its available storage classes, (2) 
the helm chart and how it is configuring the PVC / volumes, (3) networking and access to the storage in question
</li>
</ul>
</details>
