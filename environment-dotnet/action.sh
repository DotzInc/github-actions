#!/usr/bin/env bash

if [ "$GITHUB_REF_NAME" = 'main' ] || [ "$GITHUB_REF_NAME" = 'feature/154724' ]; then
    ENVIRONMENT='prd'
    ELASTIC_APM_SERVER_URL='http://10.56.0.2:8200'
    JWT_JWKS_PATH="https://api.dotz.com.br/accounts/api/default/"
elif [ "$GITHUB_REF_NAME" = 'staging' ]; then
    ENVIRONMENT='uat'
    ELASTIC_APM_SERVER_URL='http://10.204.0.112:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
elif [ "$GITHUB_REF_NAME" = 'qa' ]; then
    ENVIRONMENT='uat'
    ELASTIC_APM_SERVER_URL='http://10.204.0.112:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
else
    ENVIRONMENT='dev'
    ELASTIC_APM_SERVER_URL='http://10.221.0.114:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
fi

{
    echo ""
    if ! [ "$ENVIRONMENT" = "dev" ]; then
        echo "ELASTIC_APM_ENABLED: 'true'"
    fi
    echo "JWT_JWKS_PATH: '$JWT_JWKS_PATH'"
    echo "JKS_SAFE_IPS: '$JKS_SAFE_IPS'"
    echo "JKS_GOOGLE_PROJECTID: '$GOOGLE_PROJECTID'"
    echo "ELASTIC_APM_SERVER_URL: '$ELASTIC_APM_SERVER_URL'"
    echo "PLATFORM: 'Cloudrun'"
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
