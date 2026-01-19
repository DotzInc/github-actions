#!/usr/bin/env bash

FILE=./envs/env-dev.yaml

FILE=./envs/env-dev.yaml
ALT_FILE=./kenvs/env-dev.yaml

if [[ ! -f "$FILE" ]]; then
  FILE="$ALT_FILE"
fi

while IFS= read -r line
do
  if [[ ! $line =~ ^# ]] && [[ $line =~ [^[:space:]] ]]
  then
    IFS=":" read -r key value <<< "$line"
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    echo "$key=$value" >> "$GITHUB_ENV"
  fi
done < "$FILE"
