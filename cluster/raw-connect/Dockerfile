FROM rocker/r-ver:3.4.3
ENV DEBIAN_FRONTEND=noninteractive  
RUN apt-get update && apt-get install -y \
	ntp \
	krb5-user \
	supervisor \
	dialog \
	apt-utils \
	curl \
	rrdtool

COPY krb5.conf /etc/krb5.conf


# ssh client
RUN apt-get install -y openssh-client libpam-krb5

COPY raw-connect/supervisord.conf /etc/supervisord.conf
COPY ssh_config /etc/ssh/ssh_config

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d && \
	mkdir -p /var/log/supervisord

# create users
COPY users /tmp/users
RUN awk ' { pass=system("openssl passwd -1 "$2); system("useradd -m -p "pass" -s /bin/bash "$1) } ' /tmp/users && \
        rm /tmp/users

# install connect
RUN apt-get install -y gdebi-core wget && \
	wget https://s3.amazonaws.com/rstudio-connect/ubuntu-12.04/x86_64/rstudio-connect_1.5.12.1-10_amd64.deb && \
	dpkg -i rstudio-connect_1.5.12.1-10_amd64.deb


# when container is starting
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

