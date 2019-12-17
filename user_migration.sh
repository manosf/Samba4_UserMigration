#!/usr/bin/env bash

#Default file location of exported users
FILE="ldapusers.txt"
LINECOUNT=0
FPATH=`realpath $0 | rev | cut -d'/' -f2- | rev`
#Default User Attributes 
#Replace with your Default Settings
DOMAIN="EXAMPLE.COM"
AD_HOSTNAME="DC1"
HOME_PATH="\\\\${AD_HOSTNAME}.${DOMAIN}\\Homes\\"
PROFILE_PATH="\\\\${AD_HOSTNAME}.${DOMAIN}\\profiles\\profile-user"
HOME_DRIVE="P"
NIS_DOMAIN="example"
UNIX_HOME="/home/"
UNIX_SHELL="/bin/false"
UNIX_GID="513"
MAIL_SERVER="mail.example.com"

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
			shift 1
			;;
        --file|-f)
	        FILE=$2;
            shift 2
            ;;
        --get-users|-g)
            GETUSERS="1";
			shift 1
            ;;
	esac
done

if [ "$HELP" == "1" ];
then
    printf "Options and arguments:\n"
    echo "-h | --help Displays a usage message and exits."
    echo "-f | --file Specifies the file in which the users exist (default: ldapusers.txt)."
    echo "-g | --get-users Export users with their fullname into a txt file (default: ldapusers.txt) using a RegEx"
    exit 1
fi


if [ "$GETUSERS" == "1" ];
then
    echo "Collecting all users into ${FILE}" 
	bash ${FPATH}/user_collection.sh
fi

passwd_gen()
{
while read -r LINE|| [[ -n "${LINE}" ]];
do
	LINECOUNT=$(( $LINECOUNT + 1 ))
	#Generate random 16 character alphanumeric string
	PASS="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 16)"
	sed -i "${LINECOUNT}s~.*~${LINE}:${PASS}~" "$1"
done <"$1"
}

name_parsing()
{
LINECOUNT=0
while IFS=':' read -ra LINE; 
do
	for field in "${LINE[@]}";
	do
		REGNUM=${LINE[0]}
		NAME=${LINE[1]}
		PASS=${LINE[2]}
    	done
	echo "Your name and new password ${NAME} - ${PASS}"
	create_user
done < "$1"
}
create_user() 
{
echo "${NAME}"
SURNAME=`echo ${NAME}| cut -f1 -d " "` 
FIRSTNAME=`echo ${NAME}| cut -f2 -d " "`
NEXTUID=$((`ldbsearch -H /var/lib/samba/private/sam.ldb '(objectclass=person)' | grep uidNumber  | awk '{print $NF}' | sort -g | tail -n 1`+1))
echo " Your username is ${REGNUM}, your Surname is ${SURNAME}, your FirstName is ${FIRSTNAME} and your password is ${PASS}"
samba-tool user create $REGNUM ${PASS} \
	--use-username-as-cn \
	--given-name="${FIRSTNAME}" \
	--surname="${SURNAME}" \
	--home-drive=P \
	--home-directory="${HOME_PATH}${REGNUM}" \
	--profile-path="${PROFILE_PATH}" \
	--job-title="Student" \
	--nis-domain=cslabs \
	--uid-number="${NEXTUID}" \
	--gid-number="${UNIX_GID}" \
	--login-shell="${UNIX_SHELL}" \
	--unix-home="${UNIX_HOME}${REGNUM}/" \
	--mail-address="${REGNUM}@${MAIL_SERVER}" \
	--must-change-at-next-login
#Add user to his group
samba-tool group addmembers "Students" ${REGNUM}
#Creates User's Home Directory
mkdir /srv/samba/Students/${REGNUM}/
chown -R ${REGNUM}:"Domain Admins" /srv/samba/Students/${REGNUM}/
chmod 700 /srv/samba/Students/${REGNUM}/
#Set user's quota limit
setquota -u ${REGNUM} 204800 1433600 0 0 -a /srv
}

check_if_users_exist()
{
LINECOUNT=0
while read -r LINE|| [[ -n "${LINE}" ]];
do
	LINECOUNT=$(( $LINECOUNT + 1 ))
	if [ `wbinfo -u | grep ${REGNUM} | wc -l` -eq 1 ];
	then
		echo "Account Exists"
		sed -i "${LINECOUNT}s~.*~${LINE}:1~" "$1"
	else 
		echo "Account Doesn't Exists"
		sed -i "${LINECOUNT}s~.*~${LINE}:1~" "$1"
	fi 
done <"$1"
}

passwd_gen ${FILE}
name_parsing ${FILE}
check_if_users_exist ${FILE}
