#!/bin/bash
#
# Description : Script to change 
#


usage() { echo "Usage: $0  <username>" 1>&2; exit 1; }


if [ -z "${1}" ]; then
    usage
fi

USER_NAME=$1


LDIF_FILE=$(mktemp)

echo "
dn: uid=${USER_NAME},ou=users,dc=nurlan,dc=az
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: ${USER_NAME}
uid: ${USER_NAME}
uidNumber: ${UID_NUMBER}
gidNumber: ${GID_NUMBER}
homeDirectory: /home/${USER_NAME}
loginShell: /bin/bash
userPassword: 
shadowLastChange: 0
shadowMax: 0
shadowWarning: 0
" >> $LDIF_FILE

for i in ${OTHER_GROUPS/,/ }
do
echo "
dn: cn=$i,ou=groups,dc=nurlan,dc=az
changetype: modify
add: memberuid
memberuid: ${USER_NAME}
" >> $LDIF_FILE 
done


ldapadd -v -c -Q -Y EXTERNAL -H ldapi:/// -f $LDIF_FILE
rm $LDIF_FILE
