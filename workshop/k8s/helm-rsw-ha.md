# The Kitchen Sink of Workbench Deployments

Let's do it all!!

## Start with a Database

I have not found a fantastic solution to deploying a database within an RDS instance as a Kubernetes resource, etc. (
Although such solutions exist and are called "operators").

Although we would recommend this generally, for a proof-of-concept it "should be fine," so let's deploy a PostgreSQL
database inside of Kubernetes!

Here comes a helm chart from a third party (in a one-liner 🔥)!

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
export RSW_POSTGRES_PASS="my-password" # CHANGE ME
helm upgrade --install rsw-db bitnami/postgresql \
  --version 10.6.1 \
  --set postgresqlDatabase="rsw" \
  --set postgresqlUsername="rstudio" \
  --set postgresqlPassword="${RSW_POSTGRES_PASS}" \
  --set servicePort=5432
```

## Set up your values file

Now we need to set up ingress, sticky load balancing, storage, and connection to the database! (Did you know you could
do all that with a yaml file?)

Start a new values file called `ha-ville.yaml`, and populate with the following contents:

_ha-ville.yaml_
```yaml
replicas: 2

userCreate: true
userName: rstudio
userPassword: rstudio # CHANGE ME

homeStorage:
  create: true
  storageClassName: efs-client

config:
  secret:
    database.conf:
      provider: postgresql
      database: rsw
      username: rstudio
      password: placeholder
      host: rsw-db-postgresql.my-namespace.svc.cluster.local # CHANGE ME!

service:
  annotations:
    traefik.ingress.kubernetes.io/service.sticky.cookie: "true"
    traefik.ingress.kubernetes.io/service.sticky.cookie.name: RSW-SESSION-COOKIE
    traefik.ingress.kubernetes.io/service.sticky.cookie.secure: "true"
    
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: traefik
  hosts:
    - host: my-name-ha-rsw.training.soleng.rstudioservices.com # CHANGE ME!
      paths:
        - "/"
```

And deploy! (remember, this time we need a license _and_ a database password)

```bash
helm upgrade --install ha-ville rstudio/rstudio-workbench \
  --set license.key="${RSW_LICENSE}" \
  --set "config.secret.database\.conf.password"="${RSW_POSTGRES_PASS}" \
  -f ha-ville.yaml
```

Is it alive!? Probe your environment to see if it's working!

## What next?

You basically have everything! The only pieces missing are some config customization (maybe building your own images),
user provisioning, and some type of SSO. You can check out
the [helm chart docs](https://github.com/rstudio/helm/tree/main/charts/rstudio-workbench), start
adding [some examples](https://github.com/rstudio/helm/tree/main/examples) for customers,
or [deploy all kinds of third party software!](https://artifacthub.io/)

It's all over but the debugging 😉.
