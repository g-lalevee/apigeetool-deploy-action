echo
echo ---------------------------------------------------------------------------
echo Create Developers
echo ---------------------------------------------------------------------------

cd ./apigee-config

while IFS= read -r line; do 
  attributes=$(jq '.attributes // empty | tostring' <<< "$line");
  email=$(jq '.email // empty' <<< "$line");
  firstName=$(jq '.firstName // empty' <<< "$line");
  lastName=$(jq '.lastName // empty' <<< "$line");
  userName=$(jq '.userName // empty' <<< "$line");
  
  APIGEETOOL_COMMAND="apigeetool createDeveloper -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -o $APIGEE_ORGANIZATION"

  if [ ! -z "$attributes" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --attributes $attributes"
  fi;

  if [ ! -z "$firstName" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --firstName $firstName"
  fi;


  if [ ! -z "$email" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --email $email"
  else
    echo "Cannot createProduct: email parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    echo "APIGEETOOL_ERROR_STOP = " $APIGEETOOL_ERROR_STOP 
    if [ $APIGEETOOL_ERROR_STOP == true ]  
    then
      exit 126
    else
      RC=126
    fi;
  fi;

  if [ ! -z "$lastName" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --lastName $lastName"
  else
    echo "Cannot createProduct: lastName parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    echo "APIGEETOOL_ERROR_STOP = " $APIGEETOOL_ERROR_STOP 
    if [ $APIGEETOOL_ERROR_STOP == true ]  
    then
      exit 126
    else
      RC=126
    fi;
  fi;

  if [ ! -z "$userName" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --userName $userName"
  else
    echo "Cannot createProduct: userName parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    echo "APIGEETOOL_ERROR_STOP = " $APIGEETOOL_ERROR_STOP 
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
done < <(echo $(cat "${config_file}") | jq -c '.Developer[]?') 

cd ..