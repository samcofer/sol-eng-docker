# Helm

Getting started with Helm. Ideally you have already [gotten started with
Kubernetes](../k8s.md#getting-started-with-kubernetes) and have a development
environment functional.

Let's get started!

## What is Helm?

Helm is a Go-templating, packaging, and versioning tool for Kubernetes yaml
files. Say what?

### Go Templating

Go templating is a template syntax built into / on top of Golang (the programming language).
It uses Go syntax, parts of the Go standard library, and heavy use of braces (`{{` and `}}`) to
build / templatize documents.

When added to the world of Kubernetes YAML files, it allows things like:
  - parameterize your YAML
  - Be DRY ("don't repeat yourself") and reuse items
  - Make dynamic / run-time decisions

This unfortunately often comes at the cost of readability and simplicity.

### Packaging

Helm is oriented into packages that have versions. You can get the packages off of
your local filesystem or out of [repositories]().

This way, your kubernetes project (also known as a YAML-project)  becomes a
proper software project with [semantic versioning](), backwards compatibility
guarantees, etc. (rather than a random assortment of loosely coupled yaml files).

## Hello world example

First, you will need to [install `helm`]()! (Make sure you install Helm 3+)

From the root of the `sol-eng-docker` repository, execute the following:

```bash
helm template ./k8s/charts/hello-world
```

You should see output like what you saw in `./k8s/simple/hello-world.yaml`!

Now try to change one of the "values"

```bash
helm template ./k8s/charts/hello-world --set replicas=3
```

Do you see the change!?

### Set values in a file

Setting values on the command line can be tedious. So create a YAML file like so:

_example.yaml_
```yaml
replicas: 4
service:
  port: 80
```

Now template the chart:

```bash
helm template ./k8s/charts/hello-world -f example.yaml
```

You should see the template change! But where did I get these magic values, you ask?

```bash
helm show values ./k8s/charts/hello-world
```

This shows the different values that are available, along with their defaults.

### Now install it!

To install a helm chart, we have to give the "release" a name. In our case, it will be
`myhello`

```bash
helm install myrelease ./k8s/charts/hello-world -f example.yaml
```

Change the number of replicas in your YAML file and install again. Oops! The release already exists,
so you need to _upgrade_ it.

```bash
helm upgrade myrelease ./k8s/charts/hello-world -f example.yaml
```

As a little tip, `helm upgrade --install` will allow you to create _and_ upgrade charts, regardless of state.

### Is it alive?

Check that the helm release exists:

```bash
helm list
```

Take a look at `kubectl get pods` and `kubectl get svcs`. The pods and service were named after our release!
This is something helm charts will often do so that you can use a chart multiple times on the same cluster.

You can also specify a namespace with `-n` (as you might expect)

```bash
helm install -n mynamespace myrelease ./k8s/charts/hello-world
```

To confirm all is right with the world, let's port-forward our service.

```bash
kubectl port-forward svc/myrelease 8080:8080
```

Now navigate to http://localhost:8080 in your browser!

Well done!! You have completed your first helm release / deployment!!

## Set a repository

Now that you are "at the helm" of the `helm`-mobile (heh), let's use a real chart!

One of the great values of `helm` is that it makes it much easier to "pick and choose"
what apps you would like to deploy to your Kubernetes cluster. To do so, you need a 
helm _repository_ (basically a web server hosting some charts) and the name of the 
chart that you want to install.

Since this is RStudio, and we have some products that are fun to deploy on Kubernetes,
let's use one of our repositories!

```bash
helm repo add rstudio-beta https://cdn.rstudio.com/sol-eng/helm
```

Now what charts are here...?

```bash
helm search repo rstudio-beta
# NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                      
# rstudio-beta-s3/rstudio-connect 0.0.11                          Kubernetes deployment for RStudio Connect        
# rstudio-beta-s3/rstudio-pm      0.0.18                          Kubernetes deployment for RStudio Package Manager
# rstudio-beta-s3/rstudio-server  0.1.3                           Kubernetes deployment for RStudio Server Pro     
# rstudio-beta/rstudio-server     0.1.0                           Kubernetes deployment for RStudio Server Pro     
# rstudio-beta1/rstudio-connect   0.0.10                          Kubernetes deployment for RStudio Connect        
# rstudio-beta1/rstudio-pm        0.0.17                          Kubernetes deployment for RStudio Package Manager
# rstudio-beta1/rstudio-server    0.1.2                           Kubernetes deployment for RStudio Server Pro   
```

I mean, what did you expect? :) 

Alright! Let's install RStudio Server!

First, we will create a simple values file to make our life easier:

```yaml
replicas: 1
rbac:
  create: true
homeStorage:
  create: true
userCreate: true
```

Then ensure you have a valid RStudio license exported as the `RSP_LICENSE` environment variable.

Now, you can install RSP!

```bash
helm install myrsp rstudio-beta/rstudio-server --set license=$RSP_LICENSE
```

Notice that we reference the repository (rather than a directory structure).

### Is it alive?

Take a look at your kubernetes environment. Is RSP alive?

```bash
helm list

kubectl get pods

# please tell me you have installed the autocompletion for kubectl by now!
kubectl logs myrsp-<tab>
```

And let's use the service

```bash
kubectl port-forward svc/myrsp 8787:80
```

And login to your browser at http://localhost:8787 with user/password `rstudio/rstudio`.

You should be able to launch a session and have it _automatically_ use your Kubernetes cluster.
How cool is that!?

### A _bit_ more complex

Ok, so this chart has a _lot_ more options, and is _way_ more complex. There are
tons of nuances to dig into with `helm`. Suffice it to say that you do not need
to understand _exactly_ how a chart works if you can tweak the values to do what you want.

```bash
helm show values rstudio-beta/rstudio-server
```

We will dig into some more options in our next lesson! Have fun!
