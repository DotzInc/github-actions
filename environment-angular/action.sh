#!/usr/bin/env bash
set -e

ENV_FILE=$1

# Iterate over all environment variables passed to the script
for VAR_NAME in $(compgen -e); do
  VAR_VALUE=${!VAR_NAME}

  # Skip non-matching environment variables (only process those starting with ENV_)
  if [[ $VAR_NAME == ENV_* ]]; then
    # Strip the ENV_ prefix to get the original variable name
    ORIGINAL_VAR_NAME=${VAR_NAME#ENV_}

    echo "Updating $ORIGINAL_VAR_NAME in $ENV_FILE"
    sed -i "s|$ORIGINAL_VAR_NAME: .*|$ORIGINAL_VAR_NAME: '$VAR_VALUE',|" "$ENV_FILE"
  fi
done