#!/usr/bin/env bash

for args in $*
do
    case $args in
        --file|-f)
            FILE=$2;
            shift 2
            ;;
        --pattern|-p)
            REGEXP=$2;
            shift 2
            ;;
        --fullpath|-s)
            FPATH=$2;
            shift 2
            ;;
        --server-ip|-i)
            IP=$2;
            shift 2
            ;;
    esac
done

getent passwd | grep -E ${REGEXP} | cut -f 1,5 -d :| sort > ${FILE}
scp ldapusers.txt root@${IP}:${FPATH}/${FILE}
