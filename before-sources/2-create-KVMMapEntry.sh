echo
echo ---------------------------------------------------------------------------
echo Create KVM Entry
echo ---------------------------------------------------------------------------

cd apigee-config
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
