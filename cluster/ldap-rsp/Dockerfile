ARG RSTUDIO_VERSION
FROM rstudio/rstudio-server-pro:${RSTUDIO_VERSION}

RUN apt-get update && apt-get install -y \
    nfs-common \
    sssd \
    sssd-ldap \
    oddjob-mkhomedir

# configure ldap
COPY ./sssd.conf /etc/sssd/sssd.conf
COPY ./rstudio-sssd /etc/pam.d/rstudio
COPY ./rstudio-session-sssd /etc/pam.d/rstudio-session

COPY ./ldap-rsp/docker-entrypoint.sh /docker-entrypoint.sh

# adhoc fixes to make it work...
RUN chmod 600 /etc/sssd/sssd.conf
