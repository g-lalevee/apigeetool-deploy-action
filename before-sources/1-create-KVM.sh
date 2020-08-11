echo
echo ---------------------------------------------------------------------------
echo Create Key Value Maps
echo ---------------------------------------------------------------------------

cd apigee-config

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

