FROM  postgres:12


ENV DEBIAN_FRONTEND=noninteractive
# kerberos client
RUN apt-get update && \
  apt-get install --yes --no-install-recommends \
          ntp \
          krb5-user \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/krb5.conf.d

# create users
COPY users /tmp/users
# - leave it around to create database users, too
