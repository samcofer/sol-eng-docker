## Setup Options

There are several ways to set up access to Kubernetes.

Choose _just ONE_:

- Local
- Remote (workshop)
- Remote (AWS)

### Local Setup

- Install Docker Desktop. Enable Kubernetes (on Mac/Windows). This will give you a local kubernetes cluster
    - On linux, you might look at installing [`k3s`](./k8s/k3s.md)
        - which has less "magic" and uses less resources than `minikube`
        - Or [`k3d`](https://k3d.io) (`k3s` in docker)
    - Alternatively, `minikube`
    - `kind` is another lightweight kubernetes distribution recommended by the Kubernetes project
- Set your `context` to your local kubernetes cluster:
```bash
kubectl config get-contexts
kubectl config use-context docker-desktop
kubectl config current-context
```

### Remote Setup (workshop)

- In some internal workshops, we will provide a cluster with a `KUBECONFIG` file that you can use to connect to your own
  private / personal namespace. Reach out to `#sales-infra` or `#auth-workshop` if you have questions.
- You should have a `KUBECONFIG` file sent to you over slack. Download this file and save it in a memorable place like:
    - `~/kubeconfig-training-myname`
    - `kubeconfig-training-myname` (in the directory you are working in - the clone of this repo, for instance)
    - `~/.kube/kubeconfig-training-myname`
> NOTE: these particular configuration files are _temporary_ so do not expect them to work forever.

> NOTE: also, these values are _sensitive_. So please keep them safe!!

- We recommend editing `~/.config/git/ignore` to exclude these files from version control like so:
```bash
mkdir -p ~/.config/git/
# add this line to the file
echo 'kubeconfig-training-*' >> ~/.config/git/ignore
```

- Now set the `KUBECONFIG` environment variable to use this value (using the path to your file)

```bash
KUBECONFIG=./kubeconfig-training-myname kubectl get pods
```

- If you want to make this persistent, you can `export KUBECONFIG=/absolute/path/to/kubeconfig-training-myname`. Keep in
  mind that this will be persistent for your given shell until you modify the value, start a new shell,
  or `unset KUBECONFIG`

### Remote Setup (AWS)

> NOTE: Setup will vary. Talk to someone on your team or reach out to `#sre`!

- This setup will vary by team. It is much like the previous remote setup except you add a context to your
  "default" kubeconfig file (at `~/.kube/config`)
- It requires using AWS roles, AWS assume roles, and the `aws` CLI
- You will do something like:
```bash
AWS_DEFAULT_REGION=region aws eks update-kubeconfig --name=my-kubernetes-cluster --alias=my-kubernetes-cluster
```

### Now what?

Now we are ready to have some fun!
