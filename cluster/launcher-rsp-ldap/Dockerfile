FROM rstudio/sol-eng-rstudio:${RSTUDIO_VERSION}

ARG RSTUDIO_VERSION

RUN apt-get install -y \
    sssd \
    sssd-ldap

COPY ./launcher-rsp-ldap/rserver.conf /etc/rstudio/rserver.conf

# configure ldap
COPY ./sssd.conf /etc/sssd/sssd.conf
COPY ./rstudio-sssd /etc/pam.d/rstudio
COPY ./rstudio-session-sssd /etc/pam.d/rstudio-session

COPY ./launcher-rsp-ldap/run /etc/services.d/rstudio/run
COPY ./launcher-rsp-ldap/finish /etc/services.d/rstudio/finish
COPY ./launcher-rsp-ldap/launcher-mounts /etc/rstudio/launcher-mounts

# adhoc fixes to make it work...
RUN chmod -R 775 /etc/services.d/rstudio && \
	chmod 600 /etc/sssd/sssd.conf

COPY ./launcher.pem /etc/rstudio/launcher.pem

CMD ["/init"]
