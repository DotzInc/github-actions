#!/usr/bin/env bash
set -e

ENV_FILE=$1

if [[ ! -f "$ENV_FILE" ]]; then
  echo "O arquivo $ENV_FILE não foi encontrado!"
  exit 1
fi

TEMP_FILE=$(mktemp)
cp "$ENV_FILE" "$TEMP_FILE"

for VAR_NAME in $(compgen -e); do
  VAR_VALUE=${!VAR_NAME}

  if [[ $VAR_NAME == ENV_* ]]; then
    ORIGINAL_VAR_NAME=${VAR_NAME#ENV_}

    echo "Updating $ORIGINAL_VAR_NAME in $TEMP_FILE"
    sed -i "s|$ORIGINAL_VAR_NAME: .*|$ORIGINAL_VAR_NAME: '$VAR_VALUE',|" "$TEMP_FILE"
  fi
done

mv "$TEMP_FILE" "$ENV_FILE"
echo "Atualização concluída: $ENV_FILE foi modificado."