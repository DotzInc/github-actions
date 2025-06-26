#!/usr/bin/env bash

sleep 10
SONAR_STATUS=$(curl -s -u "$SONAR_TOKEN:" \
"$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=${{ github.event.repository.name }}")

STATUS=$(echo "$SONAR_STATUS" | jq -r '.projectStatus.status')

echo "status=$STATUS" >> $GITHUB_OUTPUT
echo "sonarqube ${{ github.event.repository.name }} status: $STATUS"
if [ "$STATUS" = "ERROR" ]; then
    echo "Quality Gate falhou!"
    exit 1
fi
