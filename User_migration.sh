#!/usr/bin/env bash

FILE="ldapusers.txt"
LINECOUNT=0
REGEXP="^p[0-9]|^mpsp[0-9]|^mppl[0-9]"
FPATH=`realpath $0 | rev | cut -d'/' -f2- | rev`
LOCALIP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
REMOTEIP="1.1.1.1"      #Replace with the desired IP of the remote server

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
        --server-ip|-i)
            REMOTEIP=$2;
            shift 2
            ;;
        --get-users|-g)
            GETUSERS="1";
            ;;
        --pattern|-p)
            REGEXP=$2;
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


if [ "$GETUSERS" == "1" ];
then
    echo "Collecting all users into ${FILE}" 
    ssh ${REMOTEIP} "bash -s" < user_collection.sh -f ${FILE} -p ${REGEXP} -s ${PATH} -i ${LOCALIP}  #Make sure to have ssh-keys authentication set up for root
fi

passwd_gen()
{
while read -r LINE|| [[ -n "${LINE}" ]];
do
	LINECOUNT=$(( $LINECOUNT + 1 ))
	PASS="$(gpg --gen-random --armor 1 10)"
	sed -i "${LINECOUNT}s/.*/${LINE}\:${PASS}/" "$1"
done <"$1"
}

name_parsing()
{
while IFS=':' read -ra ADDR; do
	for user in "${ADDR[@]}"; do
		echo $ADDR
		REGNUM=${ADDR[0]}
		#NAME=$ADDR[1]
		#PASS=ADDR[2]
	done
done <<< "$1"
}

#passwd_gen ${FILE}
name_parsing ${FILE}
