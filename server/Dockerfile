FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y apt-transport-https && \
	apt-get dist-upgrade -y

# kerberos server
RUN apt-get install -y ntp krb5-admin-server krb5-kdc supervisor

COPY kdc.conf /etc/krb5kdc/kdc.conf
COPY kadm5.acl /etc/krb5kdc/kadm5.acl
COPY krb5.conf /etc/krb5.conf

COPY supervisord.conf /etc/supervisord.conf

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d && \
	kdb5_util create -s -P pass && \
	mkdir -p /var/log/supervisord

#COPY ./krb5kdc.sh /etc/service/krb5kdc/run
#COPY ./kadmind.sh /etc/service/kadmind/run

#RUN chmod -R 755 /etc/service

EXPOSE 464
EXPOSE 749
EXPOSE 88

# when container is starting
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
