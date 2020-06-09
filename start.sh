#!/bin/bash

#LOCALHOST
APP_DIR="/code-workout/"
# EFS_DIR="/var/tmp/credentials"
#EFS_DIR="${APP_DIR}"

PORT="80"
#PORT="3000"

ENVIRONMENT=$RAILS_ENV

ERROR_FOUND=false;

# echo "Copying files from NFS conf directory"
# cp "${EFS_DIR}/database.yml" "${APP_DIR}/config/database.yml" || ERROR_FOUND=true
#chmod +x "${APP_DIR}/email_notification.sh"


#echo "rm -rf /opendsa/Books/"
#rm -rf /opendsa/Books/
#cd /opendsa
#find -type l -delete

# echo "ln -s /var/tmp/credentials/opendsa/Books /opendsa"
# ln -s /var/tmp/credentials/opendsa/Books /opendsa

#echo "Script finished."

if [[ "${ERROR_FOUND}" == true ]]; then exit 1; fi;

echo "Start cron process in foreground."

cd "${APP_DIR}"

echo "RAILS_ENV=$RAILS_ENV bundle exec thin start -p ${PORT}"

#lsof -t -i tcp:${PORT} | xargs kill -9

#echo "RAILS_ENV=$RAILS_ENV rails s  -b 0.0.0.0 -p ${PORT}"
#RAILS_ENV=${ENVIRONMENT} rails s  -b 0.0.0.0 -p ${PORT} >> /var/log/opendsa-lti.log 2>&1

# Start process ithe background - Executes delayed_jobs
nohup bash -c "rake jobs:work >> /code-workout/log/development.log 2>&1"
RAILS_ENV=${ENVIRONMENT} bundle exec thin start -p ${PORT} >> /var/log/code-workout.log 2>&1
