#!/usr/bin/env bash

if [ "$GITHUB_REF_NAME" = 'main' ]; then
    ENVIRONMENT='prd'
    ENVIRONMENT_ELK='production'
    ELASTIC_APM_SERVER_URL='http://10.56.0.2:8200'
    JWT_JWKS_PATH="https://api.dotz.com.br/accounts/api/default/"
elif [ "$GITHUB_REF_NAME" = 'staging' ]; then
    ENVIRONMENT='uat'
    ENVIRONMENT_ELK='uat'
    ELASTIC_APM_SERVER_URL='http://10.55.0.2:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
else
    ENVIRONMENT='dev'
    ENVIRONMENT_ELK='develop'
    ELASTIC_APM_SERVER_URL='http://10.221.0.114:8200'
    JWT_JWKS_PATH="https://uat.dotznext.com/accounts/api/default/"
fi

echo $ENVIRONMENT
echo $ENVIRONMENT_ELK
echo $ELASTIC_APM_SERVER_URL
echo $JWT_JWKS_PATH
echo "$APP_NAME"

# GOOGLE_PROJECTID="${{ inputs.project_id}}"
# MAX_INSTANCES="${{ inputs.max-instances }}"
# JKS_SAFE_IPS="${{ secrets.JKS_SAFE_IPS }}"
# REGION="${{ inputs.gcp-region }}"

# APPNAME="${{ inputs.app-name }}"
# VPC_CONNECTOR="vpc-connector-$ENVIRONMENT"

# # Agrega env
# echo >> ./envs/env-$ENVIRONMENT.yaml
# echo JKS_GOOGLE_PROJECTID: \'$GOOGLE_PROJECTID\' >> ./envs/env-$ENVIRONMENT.yaml
# echo ELASTIC_APM_SERVER_URL: \'$ELASTIC_APM_SERVER_URL\' >> ./envs/env-$ENVIRONMENT.yaml

# if ! grep -q "JKS_SAFE_IPS:"./envs/env-$ENVIRONMENT.yaml; then
#     echo JKS_SAFE_IPS: \'$JKS_SAFE_IPS\' >> ./envs/env-$ENVIRONMENT.yaml
# fi

# if ! [ "$ENVIRONMENT" = "dev" ]; then
# echo ELASTIC_APM_ENABLED: \'true\' >> ./envs/env-$ENVIRONMENT.yaml
# fi

# if ! grep -q "JWT_JWKS_PATH:"./envs/env-$ENVIRONMENT.yaml; then
# echo JWT_JWKS_PATH: \'$JWT_JWKS_PATH\' >> ./envs/env-$ENVIRONMENT.yaml
# fi
# if ! grep -q "JKS_ALTERNATIVE_HEADER_FORWARDED_FOR:"./envs/env-$ENVIRONMENT.yaml; then
# echo JKS_ALTERNATIVE_HEADER_FORWARDED_FOR: \'X-Forwarded-For\' >> ./envs/env-$ENVIRONMENT.yaml
# fi

# echo APPNAME: \'$APPNAME\' >> ./envs/env-$ENVIRONMENT.yaml
# echo JKS_USE_ELASTIC_APM: \'false\' >> ./envs/env-$ENVIRONMENT.yaml
# echo ELASTIC_APM_RECORDING: \'true\' >> ./envs/env-$ENVIRONMENT.yaml          
# echo ELASTIC_APM_SERVICE_NAME: \'$APPNAME\' >> ./envs/env-$ENVIRONMENT.yaml
# echo ELASTIC_APM_ENVIRONMENT: \'$ENVIRONMENT_ELK\' >> ./envs/env-$ENVIRONMENT.yaml
# echo ELASTIC_APM_CAPTURE_BODY: \'all\' >> ./envs/env-$ENVIRONMENT.yaml
# echo ELASTIC_APM_CAPTURE_BODY_CONTENT_TYPES: \'*\' >> ./envs/env-$ENVIRONMENT.yaml
# echo ELASTIC_APM_CAPTURE_HEADERS: \'true\' >> ./envs/env-$ENVIRONMENT.yaml
# echo JKS_USE_APM: \'true\' >> ./envs/env-$ENVIRONMENT.yaml