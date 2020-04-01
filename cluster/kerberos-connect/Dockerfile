ARG CONNECT_VERSION
FROM rstudio/rstudio-connect:${CONNECT_VERSION}
ENV DEBIAN_FRONTEND=noninteractive  

# ssh & kerberos
RUN apt-get update && \
    apt-get install -y sssd sssd-ldap ntp krb5-user libpam-krb5 openssh-client

COPY ./kerberos-connect/rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg

COPY krb5.conf /etc/krb5.conf

COPY ssh_config /etc/ssh/ssh_config

COPY pam /etc/pam.d/rstudio-connect
COPY pam-session /etc/pam.d/rstudio-connect-session

# create users
COPY users /tmp/users
RUN awk ' { pass=system("openssl passwd -1 "$2); system("useradd -m -p "pass" -s /bin/bash "$1) } ' /tmp/users && \
        rm /tmp/users

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d
