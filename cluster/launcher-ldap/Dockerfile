FROM rstudio/launcher-rsp-ldap

COPY ./launcher-ldap/run /etc/services.d/rstudio/run
COPY ./launcher-ldap/finish /etc/services.d/rstudio/finish

# adhoc fixes to make it work...
RUN chmod -R 777 /etc/services.d/rstudio

COPY ./launcher-ldap/launcher.conf /etc/rstudio/launcher.conf
COPY ./launcher.pub /etc/rstudio/launcher.pub
COPY ./launcher-ldap/launcher.kubernetes.profiles.conf /etc/rstudio/launcher.kubernetes.profiles.conf

CMD ["/init"]
