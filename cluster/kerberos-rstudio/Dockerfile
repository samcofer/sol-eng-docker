ARG RSTUDIO_VERSION
FROM rstudio/sol-eng-rstudio:${RSTUDIO_VERSION}

# kerberos server
RUN apt-get update && apt-get install -y ntp krb5-user libpam-krb5 openssh-client

COPY krb5.conf /etc/krb5.conf

COPY rstudio/supervisord.conf /etc/supervisord.conf
COPY ssh_config /etc/ssh/ssh_config

COPY rstudio/rserver.conf /etc/rstudio/rserver.conf
COPY pam /etc/pam.d/rstudio
COPY pam-session /etc/pam.d/rstudio-session

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d
