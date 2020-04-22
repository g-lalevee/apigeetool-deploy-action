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
#  DEPLOY CONFIGS
# ---------------------------

echo
echo
echo "Deploying all Configs Items (KVM, KVM entries, Cache, Target Servers) to [$APIGEE_ORGANIZATION / $APIGEE_ENV]"
echo
cd apigee-config

# Create Key Value Maps -----------------------------------
while IFS= read -r line; do 
  mapName=$(jq -r '.mapName // empty' <<< "$line");
  encrypted=$(jq -r '.encrypted // empty' <<< "$line");
  environment=$(jq -r '.environment // empty' <<< "$line");
  api=$(jq -r '.api // empty' <<< "$line");
  APIGEETOOL_COMMAND="apigeetool createKVMmap -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -o $APIGEE_ORGANIZATION"

  if [ ! -z "$environment" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --environment $environment"
  fi;
  if [ ! -z "$api" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --api $api"
  fi;
  if [ $encrypted ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --encrypted"
  fi;
  if [ ! -z "$mapName" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --mapName $mapName"
  else
    echo "Cannot create KVM Map: mapName is missing!"
    echo "Please correct and re-run the script."
    echo 
    echo "APIGEETOOL_ERROR_STOP = " $APIGEETOOL_ERROR_STOP 
    if [ $APIGEETOOL_ERROR_STOP == "true"] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;
  echo $APIGEETOOL_COMMAND
  $APIGEETOOL_COMMAND &> out.log || {
      head -1 out.log
      echo "Please correct and re-run the script."
      echo 
      if [ $APIGEETOOL_ERROR_STOP == "true" ] 
      then
        exit 126
      else
        RC=126
      fi;
  }
done < <(echo $(cat "${config_file}") | jq -c '.KVM[]?') 


# Add KVM Entries -----------------------------------------
while IFS= read -r line; do 
  mapName=$(jq -r '.mapName // empty' <<< "$line");
  environment=$(jq -r '.environment // empty' <<< "$line");
  api=$(jq -r '.api // empty' <<< "$line");
  entryName=$(jq -r '.entryName' <<< "$line");
  entryValue=$(jq -r '.entryValue' <<< "$line");
  APIGEETOOL_COMMAND="apigeetool addEntryToKVM -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -o $APIGEE_ORGANIZATION"
  if [ ! -z "$environment" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --environment $environment"
  fi;
  if [ ! -z "$api" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --api $api"
  fi;
  if [ ! -z "$mapName" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --mapName $mapName"
  else
    echo "Cannot add entry to KVM Map: mapName is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;
 if [ ! -z "$entryName" ]
 then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --entryName $entryName"
 else
    echo "Cannot add entry to KVM Map: entryName is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
 fi;
 if [ ! -z "$entryValue" ]
 then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --entryValue $entryValue"
 else
    echo "Cannot add entry to KVM Map: entryValue is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
 fi;
 echo $APIGEETOOL_COMMAND
 $APIGEETOOL_COMMAND &> out.log || {
      head -1 out.log
      echo "Please correct and re-run the script."
      echo 
      if [ $APIGEETOOL_ERROR_STOP == "true" ] 
      then
        exit 126
      else
        RC=126
      fi;
  }
done < <(echo $(cat "${config_file}") | jq -c '.KVMentry[]?')


# Add Caches ----------------------------------------------
while IFS= read -r line; do 
  cacheName=$(jq -r '.cacheName' <<< "$line");
  environment=$(jq -r '.environment // empty' <<< "$line");
  APIGEETOOL_COMMAND="apigeetool createcache -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -o $APIGEE_ORGANIZATION"
  if [ ! -z "$cacheName" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND -z $cacheName"
  else
    echo "Cannot create Cache: cacheName is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;
  if [ ! -z "$environment" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --environment $environment"
  else
    echo "Cannot create Cache: environment is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;
  echo $APIGEETOOL_COMMAND
  $APIGEETOOL_COMMAND &> out.log || {
    head -1 out.log
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  }
done < <(echo $(cat "${config_file}") | jq -c '.Cache[]?') 


# Add Target Servers --------------------------------------

while IFS= read -r line; do 
  targetServerName=$(jq -r '.targetServerName' <<< "$line");
  targetHost=$(jq -r '.targetHost' <<< "$line");
  targetPort=$(jq -r '.targetPort' <<< "$line");
  targetSSL=$(jq -r '.targetSSL' <<< "$line");
  targetEnabled=$(jq -r '.targetEnabled' <<< "$line"); 
  environment=$(jq -r '.environment // empty' <<< "$line");
  APIGEETOOL_COMMAND="apigeetool createTargetServer -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -o $APIGEE_ORGANIZATION"

  if [ ! -z "$environment" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --environment $environment"
  else
    echo "Cannot create Target Server: environment is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;
  if [ ! -z "$targetServerName" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --targetServerName $targetServerName"
  else
    echo "Cannot create Target Server: targetServerName is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;
  if [ ! -z "$targetHost" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --targetHost $targetHost"
  else
    echo "Cannot create Target Server: targetHost is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;
  if [ ! -z "$targetPort" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --targetPort $targetPort"
  else
    echo "Cannot create Target Server: targetPort is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;
  if [ $targetSSL ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --targetSSL"
  fi;
  if [ $targetEnabled ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --targetEnabled"
  fi;

  echo $APIGEETOOL_COMMAND
  $APIGEETOOL_COMMAND &> out.log || {
    head -1 out.log
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  }

done < <(echo $(cat "${config_file}") | jq -c '.TargetServer[]?')

cd ..

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

echo
echo "Deployment complete. Sample API proxies are deployed to the $APIGEE_ENV environment in the organization $APIGEE_ORGANIZATION"
echo "Login to enterprise.apigee.com to view and interact with the sample API proxies"

echo "::set-output name=RC::$RC"
    

