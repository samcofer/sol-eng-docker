ARG RSTUDIO_VERSION
FROM rstudio/rstudio-server-pro:${RSTUDIO_VERSION}

# kerberos server
RUN apt-get update && \
  apt-get install -y sssd sssd-ldap sssd-krb5 ntp krb5-user openssh-client oddjob-mkhomedir rsyslog

COPY ssh_config /etc/ssh/ssh_config

COPY kerb-ldap-rsp/rserver.conf /etc/rstudio/rserver.conf
COPY kerb-ldap-rsp/launcher.conf /etc/rstudio/launcher.conf

# configure ldap
COPY ./sssd-kerb.conf /etc/sssd/sssd.conf
COPY rstudio-sssd /etc/pam.d/rstudio
COPY rstudio-session-sssd /etc/pam.d/rstudio-session
COPY kerb-ldap-rsp/startup.sh /usr/local/bin/startup.sh

# trust the PEM key for dev work!!
# TODO: make this a runtime thing
COPY ssl/auth-docker.pem /auth-docker.pem
RUN cp /auth-docker.pem /usr/local/share/ca-certificates/auth-docker.crt && \
	update-ca-certificates

# put the certs into the instance in case we need them
COPY kerb-rsp-ha/certs /certs

# adhoc fixes to make it work...
RUN chmod 600 /etc/sssd/sssd.conf && \
  # so users can create their own home directories
  chmod 777 /home
