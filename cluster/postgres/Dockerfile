FROM postgres

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y apt-transport-https && \
	apt-get dist-upgrade -y

# kerberos client
RUN apt-get install -y ntp krb5-user

COPY krb5.conf /etc/krb5.conf

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d

# create users
COPY users /tmp/users
RUN awk ' { pass=system("openssl passwd -1 "$2); system("useradd -m -p "pass" -s /bin/bash "$1) } ' /tmp/users && \
        rm /tmp/users

# when container is starting
# CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
