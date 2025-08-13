#!/usr/bin/env bash
JWT_JWKS_PATH="https://api.dotz.com.br/accounts/api/default/"

{
    echo ""
    echo "JWT_JWKS_PATH: '$JWT_JWKS_PATH'"
    echo "JKS_SAFE_IPS: '$JKS_SAFE_IPS'"
    echo "JKS_GOOGLE_PROJECTID: '$GOOGLE_PROJECTID'"
    echo "ELASTIC_APM_SERVER_URL: '$ELASTIC_APM_SERVER_URL'"
} > tmpfile

cat ./envs/env-prd.yaml tmpfile > merged_temp.yaml
awk '
  BEGIN { FS=": " }
  !/^[[:space:]]*$/ && !/^#/ {
    key = $1
    if (!seen[key]) {
      print
      seen[key] = 1
    }
  }
' merged_temp.yaml > ./envs/env-prd.yaml
rm tmpfile merged_temp.yaml
