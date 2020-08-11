echo
echo ---------------------------------------------------------------------------
echo Create Cache
echo ---------------------------------------------------------------------------

cd apigee-config
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

