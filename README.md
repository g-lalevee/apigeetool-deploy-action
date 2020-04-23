[![PyPI status](https://img.shields.io/pypi/status/ansicolortags.svg)](https://pypi.python.org/pypi/ansicolortags/) 

# apigeetool deployment action 

This GitHub action deploys Apigee API Proxies, Shareflows and Apigee configuration objects (kvm, cache, hostedtarget, apiproduct, app, developer, keystore, reference, user, userrole) to an Apigee SaaS Organization / Environment, using  [Apigeetool](https://www.npmjs.com/package/apigeetool).

**This is not an official Google product.**<BR>This GitHub Action is not an official Google product, nor is it part of an official Google product. Support is available on a best-effort basis via GitHub.

***

## Inputs

#### `APIGEE_USERNAME`
Apigee User Name - string (**Required**)

#### `APIGEE_PASSWORD`
Apigee User Password - string (**Required**)

#### `APIGEETOOL_ERROR_STOP`
Stop configuration deployment execution if an error occured - true/false (**Required**)

**Notes:** Target Organization and Environment names are read from **.env** file from Github project repository. 

    APIGEE_ORGANIZATION=MyOrg
    APIGEE_ENV=MyEnv

*** 

## Outputs

#### `RC`

The Return Code of action

***

## Example usage
    ...
    jobs:
        - name: Deployment
            id: deployment
            uses: g-lalevee/apigeetool-deployment-action@v4.3
            with:
                APIGEE_USERNAME: ${{ secrets.APIGEE_ID }}
                APIGEE_PASSWORD: ${{ secrets.APIGEE_PWD }}  
                APIGEETOOL_ERROR_STOP: false
    ...




