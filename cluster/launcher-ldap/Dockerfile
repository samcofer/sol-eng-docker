FROM rstudio/launcher-rsp-ldap

COPY ./launcher-ldap/run /etc/services.d/rstudio/run
COPY ./launcher-ldap/finish /etc/services.d/rstudio/finish

# adhoc fixes to make it work...
RUN chmod -R 777 /etc/services.d/rstudio

COPY ./launcher-ldap/launcher.conf /etc/rstudio/launcher.conf
COPY ./launcher-ldap/launcher-mounts /etc/rstudio/launcher-mounts

CMD ["/init"]
