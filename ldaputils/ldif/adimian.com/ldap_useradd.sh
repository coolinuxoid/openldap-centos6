#!/bin/bash
#
# Description : Script to add users to local openldap
#


usage() { echo "Usage: $0  -u <UID number> -g <primary group> -G <other groups> <username>" 1>&2; exit 1; }

while getopts "u:g:G:" o; do
    case "${o}" in
        u)
            UID_NUMBER=${OPTARG}
            ;;
        g)
            PRIMARY_GROUP=${OPTARG}
            ;;
        G)
            OTHER_GROUPS=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${PRIMARY_GROUP}" ]|| [ -z "UID_NUMBER" ]||[ -z "$1" ]; then
    usage
fi

USER_NAME=$1

# Get GID Number from ldap
GID_NUMBER=$(ldapsearch -c -Q -Y EXTERNAL -H ldapi:/// \
-b "ou=groups,dc=nurlan,dc=az" \
cn=${PRIMARY_GROUP} gidNumber |  grep -P -o '(?<=gidNumber: )[0-9]*' )

if [ $? -eq 0 ];then
echo "GID is : $GID_NUMBER"
else
echo "Cannot find GID for PRIMARY GROUP"
exit 1
fi



LDIF_FILE=$(mktemp)

echo "
dn: uid=${USER_NAME},ou=users,dc=nurlan,dc=az
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
cn: ${USER_NAME}
uid: ${USER_NAME}
uidNumber: ${UID_NUMBER}
gidNumber: ${GID_NUMBER}
homeDirectory: /home/${USER_NAME}
loginShell: /bin/bash
userPassword: welcome1
shadowLastChange: 0
shadowMax: 0
shadowWarning: 0
" >> $LDIF_FILE

for i in ${OTHER_GROUPS/,/ }
do
echo "
dn: cn=$i,ou=groups,dc=nurlan,dc=az
changetype: modify
add: member
member: ${USER_NAME}
" >> $LDIF_FILE 
done


ldapadd -v -c -Q -Y EXTERNAL -H ldapi:/// -f $LDIF_FILE
rm $LDIF_FILE
