FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y apt-transport-https && \
	apt-get dist-upgrade -y

# kerberos server
RUN apt-get install -y ntp krb5-admin-server krb5-kdc supervisor

COPY server/kdc.conf /etc/krb5kdc/kdc.conf
COPY server/kadm5.acl /etc/krb5kdc/kadm5.acl
COPY krb5.conf /etc/krb5.conf

COPY server/supervisord.conf /etc/supervisord.conf

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d && \
	kdb5_util create -s -P pass && \
	mkdir -p /var/log/supervisord

RUN kadmin.local -q "addprinc -pw ubuntu ubuntu/admin"

EXPOSE 464
EXPOSE 749
EXPOSE 88

RUN kadmin.local -q "addprinc -pw momo bobo"

# when container is starting
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
