#!/bin/bash
# check for snyk api token
if [ -z $SNYK_TOKEN ]; then
  echo 'Missing $SNYK_TOKEN'
  exit 1
fi

# check for project path
if [ -z $PROJECT_FOLDER ]; then
  echo 'Missing $PROJECT_FOLDER'
  exit 1
fi

if [ ! -d "$PROJECT_PATH/$PROJECT_FOLDER" ]; then
  echo 'Missing project path ' \"$PROJECT_PATH/$PROJECT_FOLDER\"
  exit 2
fi

cd "$PROJECT_PATH/$PROJECT_FOLDER"

if [ -z $USER_ID ]; then
  USER_ID=`id -u`
fi

useradd -m -o -u $USER_ID -d /home/node docker-user 2>/dev/null
su docker-user -m -c "PATH=$PATH /home/node/run-snyk.sh"
