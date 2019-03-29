ARG CONNECT_VERSION
FROM rstudio/sol-eng-connect:${CONNECT_VERSION}
ENV DEBIAN_FRONTEND=noninteractive  

# ssh & kerberos
RUN apt-get install -y \
    openssh-client \
    krb5-user \
    libpam-krb5

COPY ./kerberos-connect/rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg

COPY krb5.conf /etc/krb5.conf

COPY ssh_config /etc/ssh/ssh_config

COPY pam /etc/pam.d/rstudio-connect
COPY pam-session /etc/pam.d/rstudio-connect-session

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d
