# Getting Started with k3s

The following is a tutorial on getting started with k3s (in this case, on a public EC2 instance)

### Step 1: Create ec2 instance with SSH access (and other public ports)

- ssh into the instance

### Step 2: On ec2 instance install k3s

https://rancher.com/docs/k3s/latest/en/quick-start/

```
curl -sfL https://get.k3s.io | sh -
```

### Step 3: If you have used other k8s things on this instance, tell kubectl to look in the right place

```
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

### Step 4: Enable the K8s dashboard

https://rancher.com/docs/k3s/latest/en/installation/kube-dashboard/

On the ec2 machine, run:

```
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
```

Create some files that will make the necessary user and role to access the dashboard we just made:

```
echo "
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
" > dashboard.admin-user.yml

echo "
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
" > dashboard.admin-user-role.yml

sudo k3s kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
```

Copy this token:

```
sudo k3s kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token
```

Start the magic proxy:

```
sudo k3s kubectl proxy
```

Open a new terminal and create a new ssh connection with port forwarding like so:

```
ssh -i "key.pem" -L 8001:localhost:8001 ubuntu@ec2-ip-address 
```

In your browser navigate to `localhost:8001` and supply the token. Note that the shell running `kubectl proxy` must be left open.

### Step 5 - Use K8s for something!

https://github.com/paulbouwer/hello-kubernetes

Back in a shell where you have exported `KUBECONFIG`, create a file called `hello-world.yaml` with:

```
# hello-kubernetes.yaml
apiVersion: v1
kind: Service  # this is the network config
metadata:
  name: hello-kubernetes
spec:
  type: LoadBalancer
  ports:
  - port: 4242 # pick a port that is accessible on your ec2 instance
    targetPort: 8080
  selector:
    app: hello-kubernetes
---
apiVersion: apps/v1
kind: Deployment # this is the application config
metadata:
  name: hello-kubernetes
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-kubernetes
  template:
    metadata:
      labels:
        app: hello-kubernetes
    spec:
      containers:
      - name: hello-kubernetes
        image: paulbouwer/hello-kubernetes:1.8
        ports:
        - containerPort: 8080
```

Then run:

```
kubectl apply -f hello-world.yaml
```

This deploys stuff into a default namespace. Thats a kubernetes no-no but a hello world yes-yes.

You can check things went well:

```
kubectl get pods
# application is running!
# NAME                                READY   STATUS    RESTARTS   AGE
# svclb-hello-kubernetes-cmwc9        1/1     Running   0          21m  # this is k3s magic
# hello-kubernetes-767d49787b-nt6m7   1/1     Running   0          21m  # these are what we did
# hello-kubernetes-767d49787b-z5cqj   1/1     Running   0          21m
# hello-kubernetes-767d49787b-t25lh   1/1     Running   0          21m

kubectl get services 
# NAME               TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)          AGE
# kubernetes         ClusterIP      10.43.0.1      <none>         443/TCP          54m
# hello-kubernetes   LoadBalancer   10.43.96.152   172.30.1.172   4242:32329/TCP   22m  # thats what we did!
```

Navigate to `ec2-instance-public-ip:port` and you should see an awesome hello world app. Refreshing the app should
change the pod name on the web page as your request is routed between replicas (the 3 pods listed above!) 
