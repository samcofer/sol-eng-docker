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
`myrelease`

```bash
helm install myrelease ./k8s/charts/hello-world -f example.yaml
```

Change the number of replicas in your YAML file and install again. Oops! The release already exists,
so you need to _upgrade_ it.

```bash
helm upgrade myrelease ./k8s/charts/hello-world -f example.yaml
```

> **TIP:** `helm upgrade --install` will allow you to create _and_ upgrade charts, regardless of state. Idempotency 🎉

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

### How did that work?

Now take a look at the helm chart itself by navigating to [./k8s/charts/hello-world](../../k8s/charts/hello-world).

You should see the following:

- `Chart.yaml` - the metadata about the chart, its version, etc.
- `values.yaml` - the default values for the chart
- `.helmignore` - Helm needs an ignore-file too!
- `templates` - This is the fun stuff. This is standard Kubernetes YAML (for the most part) _plus Go templating_
    - You will see some conventions here if you poke around.
    - `$.Release.Name` and `$.Release.Namespace` refer to what you think
    - `.Values.something` refers to the values provided
    - You can index deeper into values with `.Values.key.value`

A few things left out of this simple example:

- `charts` - That's right. Charts can depend on other charts. You can also specify dependencies and pin dependent
  versions in `Chart.yaml`
- `ci` - Convention is to use a `ci` folder for example `*-values.yaml` files that are used in testing, linting, and
  CI (go figure)
  
If you can wrap your head around these conventions and get used to them, you will understand literally all helm charts!
The only exception is that the layers of Go-templating get more and more confusing as the chart gets bigger / more complex.
Ideally, the layers of Go-templating would be minimal... but sometimes, our hand is forced.

## Create an ingress

Now how do we get access without port-forwarding!? This introduces the concept of "ingress"

This presumes that you have an "Ingress Controller" (i.e. a service that handles ingress definitions),
which you have automatically if you followed the [k3d directions](./k3d.md). For k3d users, you can
find your ingress controller by looking at the `kube-system` namespace (other clusters will vary).

```bash
kubectl -n kube-system get svc
kubectl -n kube-system get pods
```

`traefik` is our default ingress controller on `k3d`. So `traefik` is ready to _handle_ ingress, but
there is no ingress defined!

### Prepare the DNS name

Our DNS name is going to be `hello.localhost`. So we need to route that to our cluster. Create a record in `/etc/hosts`
that looks like the following (this will vary if you are using not-k3d, not locally, etc. You want the IP of your
ingress controller):

```
127.0.0.1       hello.localhost
```

Now if you visit that URL, you should get a very bland "404 page not found" error. This is a classic `traefik` response
when it has no idea what you are talking about. Let's teach it!

### Create the ingress

It just so happens that our helm chart is
ready [to create an ingress controller for us](../../k8s/charts/hello-world/templates/ingress.yaml), we just
have to give it the appropriate values.

So let's edit your `example.yaml` file (make sure to use YOUR name!). You also may need to change your domain, depending
on what domains your Kubernetes cluster has access to:

_example.yaml_
```yaml
replicas: 4

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: traefik
  hosts:
    - host: my-name.training.soleng.rstudioservices.com  # CHANGE ME!
      paths:
        - "/"
```

Then we can apply your update:

```bash
helm upgrade --install myrelease ./k8s/charts/hello-world -f example.yaml
```

Now visit https://the-url in your browser. Success!! You have written your first ingress!

Alternatively, you may need to wait a little while for DNS to provision... 😅

Try this to be sure that Kubernetes knows what you want:
```bash
kubectl get ingress
# NAME                      CLASS     HOSTS                                          ADDRESS   PORTS   AGE
# myrelease                 traefik   cole.training.soleng.rstudioservices.com                 80      4s
```

Once the DNS resolves properly, 

Different domains / paths can take you to different services! You are well on your way to taking
the Kubernetes world by storm!! 🎉
