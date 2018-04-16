FROM osixia/openldap

COPY schema_convert.conf schema_convert.conf
RUN apt-get update -y && \
	apt-get install -y krb5-kdc-ldap && \
	gzip -d /usr/share/doc/krb5-kdc-ldap/kerberos.schema.gz && \
	cp /usr/share/doc/krb5-kdc-ldap/kerberos.schema /etc/ldap/schema/ && \
	mkdir /tmp/ldif_output && \
	slapcat -f schema_convert.conf -F /tmp/ldif_output -n0 -s \
	"cn={12}kerberos,cn=schema,cn=config" > /tmp/cn=kerberos.ldif && \
	# modify file in place somehow....
	#perl -pe 'BEGIN{undef $/;} s/structuralObjectClass.*modifyTimestamp.*/\n/smg'
	#perl -pe 'BEGIN{undef $/;} s/(?<=^dn\: cn=)\{12\}//smg'
	#perl -pe 'BEGIN{undef $/;} s/(?<=^cn: )\{12\}//smg'
	ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /tmp/cn\=kerberos.ldif

# ldap modify
RUN ldapmodify -Q -Y EXTERNAL -H ldapi:/// .. <<! \
dn: olcDatabase={1}mdb,cn=config \
add: olcDbIndex \
olcDbIndex: krbPrincipalName eq,pres,sub \
!

# more ldap modify
RUN ldapmodify -Q -Y EXTERNAL -H ldapi:/// .. <<! \
dn: olcDatabase={1}mdb,cn=config \
replace: olcAccess \
olcAccess: to attrs=userPassword,shadowLastChange,krbPrincipalKey by dn="cn=admin,dc=example,dc=org" write by anonymous auth by self write by * none \
- \
add: olcAccess \
olcAccess: to dn.base="" by * read \
- \
add: olcAccess \
olcAccess: to * by dn="cn=admin,dc=example,dc=org" write by * read \
!

# configure kdc
RUN apt-get install -y krb5-kdc krb5-admin-server krb5-kdc-ldap
COPY krb5-ldap.conf /etc/krb5.conf

RUN kdb5_ldap_util -D cn=admin,dc=example,dc=org create -subtrees dc=example,dc=org -r EXAMPLE.COM -s -H ldap://openldap -P admin && \
	kdb5_ldap_util -D cn=admin,dc=example,dc=org stashsrvpw -f \
	/etc/krb5kdc/service.keyfile cn=admin,dc=example,dc=org

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh

