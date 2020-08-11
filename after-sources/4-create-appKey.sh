echo
echo ---------------------------------------------------------------------------
echo Create Application Keys 
echo ---------------------------------------------------------------------------

cd apigee-config
while IFS= read -r line; do 
  apiProducts=$(jq '.apiProducts // empty' <<< "$line");
  appName=$(jq '.appName // empty' <<< "$line");
  developerId=$(jq  '.developerId // empty' <<< "$line");
  key=$(jq  '.key // empty' <<< "$line");
  secret=$(jq  '.secret // empty' <<< "$line");
  APIGEETOOL_COMMAND="apigeetool createAppKey -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -o $APIGEE_ORGANIZATION"

  if [ ! -z "$apiProducts" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --apiProducts $apiProducts"
  else
    echo "Cannot createAppKey: productName parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ "$APIGEETOOL_ERROR_STOP" == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;

  if [ ! -z "$appName" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --appName $appName"
  else
    echo "Cannot createApp: appName parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ "$APIGEETOOL_ERROR_STOP" == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;

  if [ ! -z "$developerId" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --developerId $developerId"
  else
    echo "Cannot createAppKey: developerId parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ "$APIGEETOOL_ERROR_STOP" == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;

   if [ ! -z "$key" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --key $key"
  else
    echo "Cannot createAppKey: key parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ "$APIGEETOOL_ERROR_STOP" == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;

   if [ ! -z "$secret" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --secret $secret"
  else
    echo "Cannot createAppKey: secret parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ "$APIGEETOOL_ERROR_STOP" == "true" ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;


  echo $APIGEETOOL_COMMAND
  eval $APIGEETOOL_COMMAND &> out.log || {
      head -1 out.log
      echo "Please correct and re-run the script."
      echo 
      if [ "$APIGEETOOL_ERROR_STOP" == "true" ] 
      then
        exit 126
      else
        RC=126
     fi;
  }
done < <(echo $(cat "${config_file}") | jq -c '.ApplicationKey[]?') 
