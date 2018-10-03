FROM osixia/openldap

COPY ldap/schema_convert.conf schema_convert.conf
RUN apt-get update -y && \
	apt-get install -y krb5-kdc-ldap && \
	gzip -d /usr/share/doc/krb5-kdc-ldap/kerberos.schema.gz && \
	cp /usr/share/doc/krb5-kdc-ldap/kerberos.schema /etc/ldap/schema/

# configure kdc
RUN apt-get install -y krb5-kdc krb5-admin-server krb5-kdc-ldap
COPY krb5-ldap.conf /etc/krb5.conf

COPY ldap/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh

