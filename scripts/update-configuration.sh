#!/usr/bin/env bash

# chmod u+x update-configuration.sh
# ./update-configuration.sh
#
# This script makes a copy of the docker template folder.
# Recursively goes through all files and replaces all variables
# with the corresponding content from the .env file.
# And finally copies the folder to the new location.
#

RESTORE_COLOR='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
LIGHTGRAY='\033[00;37m'
CYAN='\033[00;36m'

DIR="$( cd "$( dirname "$0" )" && pwd )"
PARENT=$(dirname $DIR)

echo -e "${GREEN}> Writing application settings ${RESTORE_COLOR}"

cp -r $PARENT/templates $PARENT/.config

# Replace environment variables in all files of the folder
set -a
for file in $(find $PARENT/.config -type f)
do
    . $PARENT/.env && . $PARENT/.env-secrets && envsubst < $file > $file.tmp && mv $file.tmp $file
done
set +a

mkdir -p $PARENT/config

# copy if new or modified
rsync -raz $PARENT/.config/. $PARENT/config/

rm -r $PARENT/.config

echo -e "${GREEN}> Application settings updated${RESTORE_COLOR}"
echo ""