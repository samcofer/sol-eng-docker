# Install Tools for Kubernetes Workshop

- [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [`jq`](https://stedolan.github.io/jq/download/)
- [`helm`](https://helm.sh/docs/intro/install/)
- [`helmfile`](https://github.com/roboll/helmfile#installation) (advanced)

## Acceptance Test

Ensure that all binaries are installed and available on your PATH!

```
kubectl version

jq --version

helm version

helmfile version
```

## Troubleshooting

- Check what your PATH is: `echo $PATH`
- Figure out where the binary is installed. e.g. `find / -name 'helm'`
- Symlink the binary to a place on your PATH or modify your PATH in `~/.bashrc`, `~/.zshrc`, etc.
- Reach out to `#auth-workshop` for assistance!
