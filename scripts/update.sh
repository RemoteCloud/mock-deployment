#!/usr/bin/env bash

RESTORE_COLOR='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
LIGHTGRAY='\033[00;37m'
CYAN='\033[00;36m'

DIR="$( cd "$( dirname "$0" )" && pwd )"
PARENT=$(dirname $DIR)

echo -e "${GREEN}> Preparing application settings:${RESTORE_COLOR}"
source $DIR/update-configuration.sh



echo -e "${GREEN}> Download and start applications:${RESTORE_COLOR}"
docker-compose --project-directory $PARENT --env-file $PARENT/.env --env-file $PARENT/.env-secrets up -d 

echo -e "${YELLOW}> Waiting two minutes for application start up..:${RESTORE_COLOR}"
sleep 2m

echo -e "${GREEN}> Current application status:${RESTORE_COLOR}"
# watch -n 2 'docker ps --format "table {{.Names}}\t{{.Status}}"'
docker ps --format "table {{.Names}}\t{{.Status}}"