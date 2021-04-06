# K3s in Docker (k3d)

The [k3d]() project is k3s running in docker. If you have docker installed on your computer, congratulations!! You can
have a throw-away kubernetes cluster in minutes!

## Get Started

- Ensure docker is installed on your computer
- [Install `kubectl`](https://v1-18.docs.kubernetes.io/docs/tasks/tools/install-kubectl/) (i.e. `brew install kubectl`)
- [Install `k3d`](https://k3d.io/#installation) (i.e. `brew install k3d`)
- Create a cluster:
```bash
k3d cluster create tmp1 --servers 1 --agents 1 --api-port=6999 --port=80:80@loadbalancer --port=443:443@loadbalancer
```
    - servers are "master nodes"
    - agents are "worker nodes"
    - api-port maps to your host (i.e. is exclusive)
    - load-balancer port

- Check your context
```bash
kubectl config current-context
kubectl config get-contexts

# set your context
kubectl config use-context k3d-tmp1
```

## Other Options

- To list clusters
```bash
k3d cluster list
```
- To stop or delete a cluster (BEWARE: some stopped clusters cannot be restarted successfully...)
```bash
k3d cluster stop tmp1
k3d cluster start tmp1
k3d cluster delete tmp1
```

- (Resource intensive) A "complete" cluster needs 3 (IIRC) servers minimum. However, this can use a good bit more resources
```bash
--servers 3 --agents 2
```

- (Advanced) If you want to manage ingress yourself, add this argument to your cluster creation
```bash
--k3s-server-arg --disable=traefik 
```

- (Advanced) If you are going to expose your K3d cluster to others, you will need a SAN for your cert
```bash
--k3s-server-arg --tls-san=192.168.1.123
```

## Now what?

- Deploy fun things!!
```bash
helm repo add rstudio-beta https://cdn.rstudio.com/sol-eng/helm/
helm upgrade --install rsp rstudio-beta/rstudio-workbench --set license=$RSP_LICENSE --set userCreate=true
```
- More [here](../k8s.md) and [here](./helm.md)
