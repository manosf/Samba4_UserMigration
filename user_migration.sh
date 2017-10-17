#!/usr/bin/env bash

FILE=ldapusers.txt

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
	esac
done
