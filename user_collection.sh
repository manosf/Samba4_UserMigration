#!/usr/bin/env bash

FILE="ldapusers.txt" # File containing user account names
#You need to open port 389 or 643 at your Samba NT server to your Samba AD server 
LDAPURI="ldap://8.8.8.8:389" # SAMBA NT LDAP server URI (e.g. ldap://<IP>:389)
BASEDN="ou=users,dc=example,dc=com"  # SAMBA NT LDAP Base DN (ou=users,dc=example,dc=com) 
BINDDN="uid=admin,ou=users,dc=example,dc=com"  # LDAP Bind DN (e.g. uid=user,ou=users,dc=example,dc=com)
PASS="password"    # LDAP Bind Password
FILTER="(objectClass=person)" #Use your filter if you want

for args in $*
do
    case $args in
        --file|-f)
            FILE=$2;
            shift 2
            ;;
        --filter|-s)
            FILTER=$2;
            shift 2
            ;;
	    --bindn)
            BINDDN=$2;
            shift 2
            ;;
        --password|-p)
            PASS=$2;
            shift 2
            ;;
        --ldapuri)
            LDAPURI=$2;
            shift 2
            ;;
        --basedn)
            BASEDN=$2;
            shift 2
            ;;
    esac
done

ldapsearch -xLLL -H "${LDAPURI}" -D "${BINDDN}" -w ${PASS} -b "${BASEDN}" -s sub ${FILTER} dn | grep -v "^$" | sed 's/^dn: //' | cut -f1 -d',' | cut -f2 -d'=' > ${FILE}

while read -r LINE|| [[ -n "${LINE}" ]];
do
	LINECOUNT=$(( $LINECOUNT + 1 ))
	echo ${LINE}
	FULLNAME=`ldapsearch -xLLL -H "${LDAPURI}" -D "${BINDDN}" -w ${PASS} -b "${BASEDN}" -s sub "(uid=${LINE})" displayName | grep -v "^$\|dn:*" | cut -f 2,3 -d' '`
	sed -i "${LINECOUNT}s~.*~${LINE}:${FULLNAME}~" "$FILE"
done <"$FILE"

