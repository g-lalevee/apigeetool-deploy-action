echo
echo ---------------------------------------------------------------------------
echo Create Developer Applications
echo ---------------------------------------------------------------------------

cd apigee-config
while IFS= read -r line; do 
  apiProducts=$(jq '.apiProducts // empty' <<< "$line");
  callback=$(jq '.callback // empty' <<< "$line");
  email=$(jq  '.email // empty' <<< "$line");
  name=$(jq  '.name // empty' <<< "$line");
  APIGEETOOL_COMMAND="apigeetool createApp -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -o $APIGEE_ORGANIZATION"

  if [ ! -z "$callback" -o "$callback" == "" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --callback $callback"
  fi;

  if [ ! -z "$apiProducts" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --apiProducts $apiProducts"
  else
    echo "Cannot createApp: apiProducts parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == true ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;

  if [ ! -z "$email" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --email $email"
  else
    echo "Cannot createApp: email parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == true ] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;

  if [ ! -z "$name" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --name $name"
  else
    echo "Cannot createApp: name parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == true ] 
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
      if [ $APIGEETOOL_ERROR_STOP == true ] 
      then
        exit 126
      else
        RC=126
     fi;
  }

done < <(echo $(cat "${config_file}") | jq -c '.Application[]?') 
