#!/bin/bash

# Shell script to deploy Apigee Edge KVM (+entries), Cache, target servers,
# shared flows and api proxies, defined in this folder hierarchy:
#   | apigee-config
#   |    - config.json
#   | apigee-apiproxies
#   |    | <proxy-name-1>
#   |    |      | apiproxy
#   |    |      |    - ...
#   |    | <proxy-name-2>
#   |    |      | apiproxy
#   |    |      |    - ...
#   | apigee-sharedflows
#   |    | <sharedflow-name-1>
#   |    |      | sharedflowbundle
#   |    |      |    - ...
#   |    | <sharedflow-name-2>
#   |    |      | sharedflowbundle
#   |    |      |    - ...


# User name to log into Apigee Edge
APIGEE_USERNAME=$1
# User password to log into Apigee Edge
APIGEE_PASSWORD=$2  
# Boolean ("false, "true") to request script exit if an error occured 
# during configuration objects deployment
APIGEETOOL_ERROR_STOP=$3
RC=0

if [ -z $APIGEETOOL_ERROR_STOP ] ; then APIGEETOOL_ERROR_STOP="true"; fi;
echo "APIGEETOOL_ERROR_STOP = " $APIGEETOOL_ERROR_STOP 

# config file (JSON) name, containing KVM, Cache and target server definitions
# in ./apigee-config deirectory
config_file='config.json'

# ---------------------------------------------------------------------
# Load up .env, initialize Organization, environment and proxy names
# ---------------------------------------------------------------------

set -o allexport
[[ -f .env ]] && source .env
set +o allexport

# ---------------------------
#  TEST CONNEXION
# ---------------------------

echo Deploying to $APIGEE_ORGANIZATION.
echo
echo
echo Verifying credentials...

response=`curl -s -o /dev/null -I -w "%{http_code}" $url/v1/organizations/$APIGEE_ORGANIZATION -u $APIGEE_USERNAME:$APIGEE_PASSWORD`

if [ $response -eq 401 ]
then
  echo "Authentication failed!"
  echo "Please re-run the script using the right username/password."
  echo --------------------------------------------------
  exit 126
elif [ $response -eq 403 ]
then
  echo "Organization $APIGEE_ORGANIZATION is invalid!"
  echo "Please re-run the script using the right Organization."
  echo --------------------------------------------------
  exit 126
else
  echo "Verified! Proceeding with deployment."
fi;

# ---------------------------
#  DEPLOY CONFIGS "BEFORE"
# ---------------------------

echo START DEPLOYMENT

pwd
ls -l

for f in `ls -v ./before-sources/*.sh` ; do source $f; done


# ---------------------------
#  DEPLOY SHARED FLOWS
# ---------------------------

echo
echo Deploying all Shared Flows to $APIGEE_ENV using $APIGEE_USERNAME and $APIGEE_ORGANIZATION
cd apigee-sharedflows

for sharedflowdir in *; do
    if [ -d "${sharedflowdir}" ]; then
        #../tools/deploy.py -n $proxydir -u $username:$password -o $org -e $env -p / -d $proxydir -h $url
        apigeetool deploySharedFlow -o $APIGEE_ORGANIZATION -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -e $APIGEE_ENV -n $sharedflowdir -d $sharedflowdir 
        if [ $? -ne 0 ] 
        then
          if [ $APIGEETOOL_ERROR_STOP == "true" ] 
          then
            exit 126
          else
            RC=126
          fi;
        fi;
    fi
done

cd ..

# ---------------------------
#  DEPLOY PROXIES
# ---------------------------

echo
echo Deploying all API Proxies to $APIGEE_ENV using $APIGEE_USERNAME and $APIGEE_ORGANIZATION
cd apigee-apiproxies

for proxydir in *; do
    if [ -d "${proxydir}" ]; then
        #../tools/deploy.py -n $proxydir -u $username:$password -o $org -e $env -p / -d $proxydir -h $url
        apigeetool deployproxy -o $APIGEE_ORGANIZATION -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -e $APIGEE_ENV -n $proxydir -d $proxydir
        if [ $? -ne 0 ] 
        then
          if [ $APIGEETOOL_ERROR_STOP == "true" ] 
          then
            exit 126
          else
            RC=126
          fi;
        fi;
    fi
done

cd ..

# ---------------------------
#  DEPLOY CONFIGS "AFTER"
# ---------------------------

echo START DEPLOYMENT

for f in `ls -v ./after-sources/*.sh` ; do source $f; done


# ---------------------------
#  END
# ---------------------------

echo
echo "Deployment complete. Sample API proxies are deployed to the $APIGEE_ENV environment in the organization $APIGEE_ORGANIZATION"
echo "Login to enterprise.apigee.com to view and interact with the sample API proxies"

echo "::set-output name=RC::$RC"
    

