#!/bin/bash

# check for snyk api token
if [ -z $SNYK_TOKEN ]; then
  echo 'Missing $SNYK_TOKEN'
  exit 1
fi

# check for project path
cd "$PROJECT_PATH"
if [ $? -ne "0" ]; then
  echo 'Invalid project path ' \"$PROJECT_PATH\"
  exit 2
fi

TEST_SETTINGS="";
if [ ! -z $TARGET_FILE ]; then
  TEST_SETTINGS="--file=${TARGET_FILE} "
fi

if [ ! -z $ORGANIZATION ]; then
  TEST_SETTINGS="${TEST_SETTINGS} --org=${ORGANIZATION}"
fi

if [ ! -z $ENV_FLAGS ]; then
  TEST_SETTINGS="${TEST_SETTINGS} -- ${ENV_FLAGS}"
fi

snyk test --json $TEST_SETTINGS > /tmp/res.json
RC=$?
cat /tmp/res.json

if [ $RC -ne "0" ] && [ $RC -ne "1" ]; then
  echo $RC
  exit 3;
fi

cat /tmp/res.json | jq '.vulnerabilities|= map(. + {severity_numeric: (if(.severity) == "high" then 1 else (if(.severity) == "medium" then 2 else (if(.severity) == "low" then 3 else 4 end) end) end)}) |.vulnerabilities |= sort_by(.severity_numeric) | del(.vulnerabilities[].severity_numeric)' | snyk-to-html | sed 's/<\/head>/  <link rel="stylesheet" href="snyk_report.css"><\/head>/' > /tmp/snyk_report.html
cat /home/node/snyk_report.css > /tmp/snyk_report.css
# check monitor
if [ ! -z $MONITOR ]; then
  snyk monitor $TEST_SETTINGS
fi
exit $RC