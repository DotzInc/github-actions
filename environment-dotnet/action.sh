#!/usr/bin/env bash

if [ "$GITHUB_REF_NAME" = 'main' ]; then
    ENVIRONMENT='prd'
    ENVIRONMENT_ELK='production'
    ELASTIC_APM_SERVER_URL='http://10.56.0.2:8200'
    JWT_JWKS_PATH="https://api.dotz.com.br/accounts/api/default/"
elif [ "$ENV" = 'staging' ]; then
    ENVIRONMENT='uat'
    ENVIRONMENT_ELK='uat'
    ELASTIC_APM_SERVER_URL='http://10.221.0.114:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
else
    ENVIRONMENT='dev'
    ENVIRONMENT_ELK='develop'
    ELASTIC_APM_SERVER_URL='http://10.221.0.114:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
fi

{
    echo ""
    if ! [ "$ENVIRONMENT" = "dev" ]; then
        echo ELASTIC_APM_ENABLED: \'true\'
    fi
    echo JKS_ALTERNATIVE_HEADER_FORWARDED_FOR: \'X-Forwarded-For\'
    echo JWT_JWKS_PATH: \'$JWT_JWKS_PATH\'
    echo JKS_SAFE_IPS: \'"$JKS_SAFE_IPS"\'
    echo JKS_GOOGLE_PROJECTID: \'"$GOOGLE_PROJECTID"\'
    echo ELASTIC_APM_SERVER_URL: \'$ELASTIC_APM_SERVER_URL\'
    echo APPNAME: \'"$APPNAME"\'
    echo JKS_USE_ELASTIC_APM: \'false\'
    echo ELASTIC_APM_RECORDING: \'true\'
    echo ELASTIC_APM_SERVICE_NAME: \'"$APPNAME"\'
    echo ELASTIC_APM_ENVIRONMENT: \'$ENVIRONMENT_ELK\'
    echo ELASTIC_APM_CAPTURE_BODY: \'all\'
    echo ELASTIC_APM_CAPTURE_BODY_CONTENT_TYPES: \'*\'
    echo ELASTIC_APM_CAPTURE_HEADERS: \'true\'
    echo JKS_USE_APM: \'true\'
    echo PLATFORM: \'Cloudrun\'
    
} > tmpfile

cat ./envs/env-$ENVIRONMENT.yaml tmpfile > merged_temp.yaml
awk '
  BEGIN { FS=": " }
  !/^[[:space:]]*$/ && !/^#/ {
    key = $1
    if (!seen[key]) {
      print
      seen[key] = 1
    }
  }
' merged_temp.yaml > ./envs/env-$ENVIRONMENT.yaml
rm tmpfile merged_temp.yaml