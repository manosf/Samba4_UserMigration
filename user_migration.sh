#!/usr/bin/env bash

FILE="ldapusers.txt"
LINECOUNT=0
REGEXP="^p[0-9]|^mpsp[0-9]|^mppl[0-9]"

if [ "$EUID" != "0" ]; 
then
	echo "This script must be run as root" 1>&2
	exit 
fi

for args in $*
do
	case $args in
		--help|-h)
			HELP="1";
			;;
		--file|-f)
			FILE=$2;
			shift 2
			;;
		--get-users|-g)
			GETUSERS="1";
			;;
        --pattern|-p)
            REGEXP=$3;
            shift 2
            ;;
	esac
done

if [ "$HELP" == "1" ];
then
    printf "Options and arguments:\n"
	echo "-h | --help Displays a usage message and exits."
    echo "-f | --file Specifies the file in which the users exist (default: ldapusers.txt)."
    echo "-g | --get-users Export users with their fullname into a txt file (default: ldapusers.txt) using a RegEx"
    echo "-p | --pattern Specifies the Regular Expersion you want to use to collect User data into a file"
    exit 1
fi

if [ "$GETUSERS" == "1" ]
then
    echo "Collecting all Users into ${FILE} "
    getent passwd | grep -E ${REGEXP} | cut -f 1,5 -d :| sort > ${FILE}
    exit 1
fi
passwd_gen()
{
while read -r LINE|| [[ -n "${LINE}" ]];
do
	LINECOUNT=$(( $LINECOUNT + 1 ))
	PASS="$(gpg --gen-random --armor 1 10)"
	sed -i "${LINECOUNT}s/.*/${LINE}\, ${PASS}/" "$1"
done <"$1"
}

passwd_gen ${FILE}
