echo
echo ---------------------------------------------------------------------------
echo Create Target Servers
echo ---------------------------------------------------------------------------

cd ./apigee-config

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