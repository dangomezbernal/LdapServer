#! /bin/bash


rm -rf /var/lib/ldap/*
rm -rf /etc/ldap/slapd.d/*
slaptest -f slapd.conf -F /etc/ldap/slapd.d
slapadd -F /etc/ldap/slapd.d -l edt-org.ldif
chown openldap.openldap /etc/ldap/slapd.d/ /var/lib/ldap/
/usr/sbin/slapd -d0
