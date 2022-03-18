## Get Started with RStudio!!

Ok, now we need to deploy a pro product to Kubernetes! Let's deploy the IDE!

First, we need a license! Ensure you have the environment variable `RSW_LICENSE`
exported with a real RStudio license

```bash
export RSW_LICENSE=xxxx
```

Now we will store this license on the Kubernetes cluster, where it will be accessible
to the RSP service that we deploy. Kubernetes stores such things as **secrets**

```bash
kubectl create secret generic license --from-literal="rsw=$RSW_LICENSE"
```

From the [`k8s/simple`](../../k8s/simple) directory, execute the following:
```bash
kubectl apply -f rsw.yaml
```

Now we will make sure all is well with the world
```bash
kubectl get pods
kubectl logs rsw-<name of pod>
```

And port-forward the service:
```bash
kubectl port-forward svc/rsw 8787:80
```

Then log in with user:password `rstudio:rstudio` and look at the output of `system('hostname')`.
That's the name of your pod!! Well done!

```r
system("hostname")
# rsw-78f9f9b56d-pqsvm
```

Again, to remove:
```bash
kubectl delete -f rsw.yaml
```

### New Concepts

Take a look at [rsw.yaml](../../k8s/simple/rsw.yaml)

- Notice how we mounted the secret into the container as an environment variable
- RSW by default requires a "privileged" container (akin to root on the Kubernetes node). We did this
  with `securityContext` (we should really relax this default...)
- Notice the commented out `command`. This can be a hacky but useful tool if
  our products are starting up weirdly
