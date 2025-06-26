#!/usr/bin/env bash

PROJECT_RESPONSE=$(curl -s -u "$SONAR_TOKEN:" \
"$SONAR_HOST_URL/api/qualitygates/get_by_project?project=${{ github.event.repository.name }}")

QUALITY_GATE_NAME=$(echo "$PROJECT_RESPONSE" | jq -r '.qualityGate.name')
QUALITY_GATE_NAME=$(echo "$QUALITY_GATE_NAME" | jq -sRr @uri)

echo "Quality Gate Name: $QUALITY_GATE_NAME"

GATE_RESPONSE=$(curl -s -u "$SONAR_TOKEN:" \
"$SONAR_HOST_URL/api/qualitygates/show?name=$QUALITY_GATE_NAME")

NEW_COV_CONDITION_ID=$(echo "$GATE_RESPONSE" | jq -r '.conditions[] | select(.metric=="coverage") | .id')
CURRENT_NEW_COV=$(echo "$GATE_RESPONSE" | jq -r '.conditions[] | select(.metric=="coverage") | .error')
LEGACY_COV_NUM=${{ steps.coverage-calc.outputs.coverage }}

if [ -n "$NEW_COV_CONDITION_ID" ]; then
    CURRENT_NEW_COV_NUM=$(echo "$CURRENT_NEW_COV" | sed 's/[^0-9.]*//g')

    if (( $(echo "$LEGACY_COV_NUM > $CURRENT_NEW_COV_NUM" | bc -l) )); then
        if (( $(echo "$LEGACY_COV_NUM > 80" | bc -l) )); then
            echo "Legacy coverage ($LEGACY_COV_NUM%) > 80%, updating new_coverage threshold to 80%"
            curl -u "$SONAR_TOKEN:" -X POST \
            "$SONAR_HOST_URL/api/qualitygates/update_condition" \
            -d "id=$NEW_COV_CONDITION_ID&metric=new_coverage&op=LT&error=80"
        else
            echo "Updating new_coverage threshold from $CURRENT_NEW_COV to $LEGACY_COV_NUM%"
            curl -u "$SONAR_TOKEN:" -X POST \
            "$SONAR_HOST_URL/api/qualitygates/update_condition" \
            -d "id=$NEW_COV_CONDITION_ID&metric=new_coverage&op=LT&error=$LEGACY_COV_NUM"
        fi
    else
        echo "Legacy coverage ($LEGACY_COV_NUM%) not greater than current new_coverage ($CURRENT_NEW_COV), keeping existing configuration"
    fi
else
    echo "Criando nova condição para new_coverage"
    curl -u "$SONAR_TOKEN:" -X POST \
    "$SONAR_HOST_URL/api/qualitygates/create_condition" \
    -d "gateName=$QUALITY_GATE_NAME&metric=new_coverage&op=LT&error=$LEGACY_COV_NUM"
fi
