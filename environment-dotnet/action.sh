#!/usr/bin/env bash

if [ "$GITHUB_REF_NAME" = 'main' ]; then
    ENVIRONMENT='prd'
    ELASTIC_APM_SERVER_URL='http://elastic.noverde.com:8200'
    JWT_JWKS_PATH="https://api.dotz.com.br/accounts/api/default/"
elif [ "$GITHUB_REF_NAME" = 'staging' ]; then
    ENVIRONMENT='uat'
    ELASTIC_APM_SERVER_URL='http://elastic.uat.noverde.com:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
elif [ "$GITHUB_REF_NAME" = 'qa' ]; then
    ENVIRONMENT='uat'
    ELASTIC_APM_SERVER_URL='http://elastic.uat.noverde.com:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
else
    ENVIRONMENT='dev'
    ELASTIC_APM_SERVER_URL='http://elastic.dev.noverde.com:8200'
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
