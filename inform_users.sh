#!/bin/bash

FILE="ldapusers.txt"
LINECOUNT=0
MAIL_SERVER="mail.example.com"

while IFS=':' read -ra LINE;
do
	for field in "${LINE[@]}";
	do
		REGNUM=${LINE[0]}
		NAME=${LINE[1]}
		PASS=${LINE[2]}
		EXIST=${LINE[3]}
	done
	if [ ${EXIST}=1 ];
	then
		echo "Your name and new password ${NAME} - ${PASS}" | mail -s "Password Reset - New Password" -a "From: postmaster@${MAIL_SERVER}" ${REGNUM}@${MAIL_SERVER}
	else
		echo "There is no such user"
	fi	       
done < "${FILE}"

