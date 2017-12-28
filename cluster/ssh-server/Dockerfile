FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y apt-transport-https && \
	apt-get dist-upgrade -y

# kerberos server
RUN apt-get install -y ntp krb5-user supervisor

COPY krb5.conf /etc/krb5.conf

# ssh server
RUN apt-get install -y openssh-server

COPY ssh-server/sshd_config /etc/ssh/sshd_config

COPY ssh-server/supervisord.conf /etc/supervisord.conf

# make directories
RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d && \
	mkdir -p /var/log/supervisord && \
	mkdir -p /var/run/sshd

# create a user
RUN useradd -m -p $(openssl passwd -1 momo) -s /bin/bash bobo

# when container is starting
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
