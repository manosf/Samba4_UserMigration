#!/usr/bin/env bash

PATH=`realpath "user_collection" | rev | cut -d'/' -f2- | rev`
IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

getent passwd | grep -E ${REGEXP} | cut -f 1,5 -d :| sort > ldapusers.txt
scp ldapusers.txt ${IP}:${PATH}/ldapusers.txt
