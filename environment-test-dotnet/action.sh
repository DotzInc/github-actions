#!/usr/bin/env bash

FILE=./envs/env-dev.yaml
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
