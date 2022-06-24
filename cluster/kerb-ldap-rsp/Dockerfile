ARG RSTUDIO_VERSION
FROM rstudio/rstudio-workbench:${RSTUDIO_VERSION}

# kerberos client
RUN apt-get update && \
  apt-get install --yes --no-install-recommends \
          ntp \
          krb5-user \
          rsyslog \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ssh_config /etc/ssh/ssh_config

# configure ldap
COPY ./sssd-kerb.conf /etc/sssd/conf.d/
RUN chmod 600 /etc/sssd/conf.d/sssd-kerb.conf \
 && mkdir -p /etc/krb5.conf.d \
 && echo "[libdefaults]\n default_ccache_name = KEYRING:persistent:%{uid}" > /etc/krb5.conf.d/ccache-name.conf

ENV DRIVERS_VERSION=2021.10.0
# ODBC and drivers
RUN curl -O https://cdn.rstudio.com/drivers/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    apt-get update && \
    apt-get install --yes --no-install-recommends unixodbc unixodbc-dev && \
    apt-get install --yes --no-install-recommends ./rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* ./rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini
