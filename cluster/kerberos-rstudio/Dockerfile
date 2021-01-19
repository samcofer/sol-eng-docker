ARG RSTUDIO_VERSION
FROM rstudio/rstudio-server-pro:${RSTUDIO_VERSION}

# kerberos server
RUN apt-get update && \
  apt-get install -y sssd sssd-ldap ntp krb5-user libpam-krb5 openssh-client oddjob-mkhomedir rsyslog

COPY krb5.conf /etc/krb5.conf

COPY ssh_config /etc/ssh/ssh_config

COPY kerberos-rstudio/rserver.conf /etc/rstudio/rserver.conf
COPY pam /etc/pam.d/rstudio
COPY pam-session /etc/pam.d/rstudio-session
COPY kerberos-rstudio/startup.sh /usr/local/bin/startup.sh

# create users
COPY users /tmp/users
RUN awk ' { pass=system("openssl passwd -1 "$2); system("useradd -m -p "pass" -s /bin/bash "$1) } ' /tmp/users && \
        rm /tmp/users

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d

# trust the PEM key for dev work!!
# TODO: make this a runtime thing
COPY ssl/auth-docker.pem /auth-docker.pem
RUN cp /auth-docker.pem /usr/local/share/ca-certificates/auth-docker.crt && \
	update-ca-certificates

# put the certs into the instance in case we need them
COPY kerb-rsp-ha/certs /certs
