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

First, we will create a simple values file to make our life
easier. [There are some other examples here](https://github.com/rstudio/helm/tree/main/examples/workbench):

```yaml
replicas: 1
rbac:
  create: true
userCreate: true
```

Then ensure you have a valid RStudio license exported as the `RSW_LICENSE` environment variable.

Now, you can install RSW!

```bash
helm upgrade --install myrsw rstudio/rstudio-workbench --set license.key=$RSW_LICENSE
```

Notice that we reference the repository (rather than a directory structure). It is also possible to pin a version (
with `--version`), but we have not done that here. If you are doing this "for real," you should definitely pin your
chart versions 😅

### Is it alive?

Take a look at your kubernetes environment. Is RSW alive?

```bash
helm list

kubectl get pods

# please tell me you have installed the autocompletion for kubectl by now!
kubectl logs myrsw-<tab>
```

And let's use the service

```bash
# if you need to get the service name: kubectl get svc
kubectl port-forward svc/myrsw 8787:80
```

And login to your browser at http://localhost:8787 with user/password `rstudio/rstudio`.

You should be able to launch a session successfully! However, you are using the Local Launcher and nobody else can use
your server... we can do better than that.

### Ingress

Let's tackle the first step of this - expose our app to the world.


There is still much to be done! Nothing is persistent (yet), and we want to use the Kubernetes Launcher!

### A _bit_ more complex

Ok, so this chart has a _lot_ more options, and is _way_ more complex. There are
tons of nuances to dig into with `helm`. Suffice it to say that you do not need
to understand _exactly_ how a chart works if you can tweak the values to do what you want.

```bash
helm show values rstudio/rstudio-workbench
```

We will dig into some more options in our next lesson! Have fun!
