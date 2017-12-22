FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y apt-transport-https && \
	apt-get dist-upgrade -y

# kerberos server
RUN apt-get install -y ntp krb5-user supervisor \
	libpam-krb5

RUN apt-get install -y r-base gdebi-core && \
	wget https://download2.rstudio.org/rstudio-server-pro-1.1.383-amd64.deb && \
	gdebi rstudio-server-pro-1.1.383-amd64.deb


COPY krb5.conf /etc/krb5.conf

COPY rstudio/supervisord.conf /etc/supervisord.conf

COPY rstudio/rserver.conf /etc/rstudio/rserver.conf
COPY rstudio/pam-rstudio /etc/pam.d/rstudio
COPY rstudio/pam-rstudio-session /etc/pam.d/rstudio-session

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d && \
	mkdir -p /var/log/supervisord

# create a user
RUN useradd -m -p $(openssl passwd -1 momo) -s /bin/bash bobo

# when container is starting
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]


# https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/devel/Dockerfile
# https://www.rstudio.com/products/rstudio/download-commercial/ 
