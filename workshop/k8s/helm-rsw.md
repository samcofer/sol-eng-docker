# Deploy RStudio Workbench with Helm

## Set a repository

Now that you are "at the helm" of the `helm`-mobile (heh), let's use a real chart!

One of the great values of `helm` is that it makes it much easier to "pick and choose"
what apps you would like to deploy to your Kubernetes cluster. To do so, you need a
helm _repository_ (basically a web server hosting some charts) and the name of the
chart that you want to install.

Since this is RStudio, and we have some products that are fun to deploy on Kubernetes,
let's use our public repository!

```bash
helm repo add rstudio https://helm.rstudio.com
```

Now what charts are here...?

```bash
helm search repo rstudio/
# NAME                            CHART VERSION   APP VERSION             DESCRIPTION                                       
# rstudio/prepull-daemonset       0.0.2                                   a daemonset to prepull images so they are cached  
# rstudio/rstudio-connect         0.2.23          2022.02.3               Official Helm chart for RStudio Connect           
# rstudio/rstudio-launcher-rbac   0.2.10          0.2.10                  RBAC definition for the RStudio Job Launcher      
# rstudio/rstudio-library         0.1.20          0.1.20                  Helm library helpers for use by Official RStudi...
# rstudio/rstudio-pm              0.3.3           2021.12.0-3             Official Helm chart for RStudio Package Manager   
# rstudio/rstudio-workbench       0.5.8           2021.09.2-382.pro1      Official Helm chart for RStudio Workbench     
```

I mean, what did you expect? 😄 (You can ignore the ones you do not recognize). There are _tons_ of repositories out
there. You can search some of them on [ArtifactHub](https://artifacthub.io/) or find them on GitHub, in your favorite
search engine, etc.

Alright! Let's install RStudio Workbench!

## Install RStudio Workbench

First, we will create a simple values file called `rsw.yaml` to make our life
easier. [There are some other examples here](https://github.com/rstudio/helm/tree/main/examples/workbench):

_rsw.yaml_
```yaml
replicas: 1

userCreate: true
userName: rstudio
userPassword: rstudio # CHANGE ME

config:
  server:
    jupyter.conf:
      jupyter-exe: /opt/python/jupyter/bin/jupyter
    launcher.local.conf:
      unprivileged: 1
    launcher.conf:
      cluster:
        name: Local
        type: Local
```

Then ensure you have a valid RStudio license exported as the `RSW_LICENSE` environment variable.

Now, you can install RSW!

```bash
helm upgrade --install myrsw rstudio/rstudio-workbench -f rsw.yaml --set license.key=$RSW_LICENSE
```

Notice that we reference the repository (rather than a directory structure). It is also possible to pin a version (
with `--version`), but we have not done that here. If you are doing this "for real," you should definitely pin your
chart versions 😅

### Is it alive?

Take a look at your kubernetes environment. Is RSW alive?

```bash
helm list

kubectl get pods

kubectl describe pod myrsw-<tab> rstudio
kubectl get pod myrsw-<tab> -o yaml

# please tell me you have installed the autocompletion for kubectl by now!
kubectl logs myrsw-<tab> rstudio -f
```

And let's use the service

```bash
# if you need to get the service name: kubectl get svc
kubectl port-forward svc/myrsw-rstudio-workbench 8787:80
```

And login to your browser at http://localhost:8787 with user/password `rstudio/rstudio`.

You should be able to launch a session successfully! However, you are using the Local Launcher and nobody else can use
your server... we can do better than that.

### Ingress

Let's tackle the first step of this - expose our app to the world.

What we need to define here is called an "Ingress". Open up the `rsw.yaml` file that you started, and add this section
to the bottom:

_rsw.yaml_
```yaml
# ...

ingress:
  enabled: true
  ingressClassName: "traefik"
  hosts:
    - host: my-name-rsw.training.soleng.rstudioservices.com # CHANGE ME!
      paths:
        - /
```

Now deploy again with the same command:
```bash
helm upgrade --install myrsw rstudio/rstudio-workbench -f rsw.yaml --set license.key=$RSW_LICENSE
```

And you should see another ingress now!

```bash
kubectl get ingress
# NAME                      CLASS     HOSTS                                          ADDRESS   PORTS   AGE
# myrelease                 traefik   cole.training.soleng.rstudioservices.com                 80      4s
# myrsw-rstudio-workbench   traefik   cole-rsw.training.soleng.rstudioservices.com             80      4m27s
```

There is still much to be done! Nothing is persistent (yet), and we want to use the Kubernetes Launcher!

### A _bit_ more complex

Ok, so this chart has a _lot_ more options, and is _way_ more complex. There are
tons of nuances to dig into with `helm`. Suffice it to say that you do not need
to understand _exactly_ how a chart works if you can tweak the values to do what you want.

```bash
helm show values rstudio/rstudio-workbench
```

We will dig into some more options in our next lesson! Have fun!

### Cleanup

If you are done and want to clean up (so you can play nicely with the cluster):

```bash
helm list
helm delete myrsw
```
