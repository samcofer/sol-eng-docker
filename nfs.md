# NFS

We have more NFS documents at the bottom of [./k8s.md](./k8s.md), since that is
the place that this becomes most relevant. 

However, NFS is a pain to debug, so a separate file is also in order.

## Common Problems

- Set `privileged: true` if you are in a docker container or on Kubernetes
- `exportfs -a` if you want to [refresh the exports](https://unix.stackexchange.com/questions/106122/mount-nfs-access-denied-by-server-while-mounting-on-ubuntu-machines)
- [expose ports 111 and 2049](https://serverfault.com/questions/377170/which-ports-do-i-need-to-open-in-the-firewall-to-use-nfs)
- use [`showmount -e nfs-server`](https://www.cyberciti.biz/faq/howto-see-shares-on-nfs-server-exported-filesystems/) to see exports


## [Add logging](https://kerneltalks.com/config/nfs-logs-in-linux/)

```
rpcdebug -m nfsd all
```

## [Useful debugging](http://nfs.sourceforge.net/nfs-howto/ar01s07.html)

- First, check that NFS actually is running on the server by typing rpcinfo -p
  on the server
- Now check to make sure you can see it from the client. On the client, type
  rpcinfo -pserver where server is the DNS name or IP address of your server.


## Other Articles

- [Access denied](https://www.centos.org/forums/viewtopic.php?t=56673)
- [Install on Ubuntu](https://help.ubuntu.com/lts/serverguide/network-file-system.html.en)
- [Encrypting nfs...?](https://www.linuxjournal.com/content/encrypting-nfsv4-stunnel-tls)
