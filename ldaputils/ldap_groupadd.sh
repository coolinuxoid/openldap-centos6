#!/bin/bash
#
# Description : Script to add group to local openldap
#


usage() { echo "Usage: $0  -g <GID number> <Group NAME>" 1>&2; exit 1; }

while getopts "g:" o; do
    case "${o}" in
        g)
            GID_NUMBER=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${GID_NUMBER}" ]|| [ -z "$1" ]; then
    usage
fi

GROUP_NAME=$1


LDIF_FILE=$(mktemp)

echo "
dn: cn=$GROUP_NAME,ou=groups,dc=nurlan,dc=az
objectClass: top
objectClass: posixGroup
gidNumber: $GID_NUMBER
" >> $LDIF_FILE


ldapadd -v -c -Q -Y EXTERNAL -H ldapi:/// -f $LDIF_FILE
rm $LDIF_FILE
