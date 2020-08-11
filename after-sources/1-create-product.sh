echo
echo ---------------------------------------------------------------------------
echo Create Products
echo ---------------------------------------------------------------------------

cd apigee-config
while IFS= read -r line; do 
  productName=$(jq '.productName // empty' <<< "$line");
  productDesc=$(jq '.productDesc // empty' <<< "$line");
  environments=$(jq  '.environments // empty' <<< "$line");
  scopes=$(jq  '.scopes // empty' <<< "$line");
  proxies=$(jq  '.proxies // empty' <<< "$line");
  quota=$(jq  '.quota // empty' <<< "$line");
  proxies=$(jq  '.proxies // empty' <<< "$line");
  quotaInterval=$(jq  '.quotaInterval // empty' <<< "$line");
  quotaTimeUnit=$(jq  '.quotaTimeUnit // empty' <<< "$line");
  APIGEETOOL_COMMAND="apigeetool createProduct -u $APIGEE_USERNAME -p $APIGEE_PASSWORD -o $APIGEE_ORGANIZATION"

  if [ ! -z "$displayName" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --displayName $displayName"
  fi;

  if [ ! -z "$quota" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --quota $quota"
  fi;

  if [ ! -z "$quotaInterval" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --quotaInterval $quotaInterval"
  fi;

  if [ ! -z "$quotaTimeUnit" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --quotaTimeUnit $quotaTimeUnit"
  fi;

  if [ ! -z "$productDesc" ] 
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --productDesc $productDesc"
  fi;

  if [ ! -z "$productName" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --productName $productName"
  else
    echo "Cannot createProduct: productName parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == true ]  
    then
      exit 126
    else
      RC=126
    fi;
  fi;

  if [ ! -z "$proxies" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --proxies $proxies"
  else
    echo "Cannot createProduct: proxies parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == true] 
    then
      exit 126
    else
      RC=126
    fi;
  fi;

  if [ ! -z "$environments" ]
  then
    APIGEETOOL_COMMAND="$APIGEETOOL_COMMAND --environments $environments"
  else
    echo "Cannot createProduct: environments parameter is missing!"
    echo "Please correct and re-run the script."
    echo 
    if [ $APIGEETOOL_ERROR_STOP == true] 
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
done < <(echo $(cat "${config_file}") | jq -c '.Product[]?') 
