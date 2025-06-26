#!/usr/bin/env bash

sleep 5
SONAR_STATUS=$(curl -s -u "$SONAR_TOKEN:" \
"$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$SONAR_PROJECT_KEY")

# Extract overall status
STATUS=$(echo "$SONAR_STATUS" | jq -r '.projectStatus.status')

# Process failing conditions
echo "SonarQube Quality Gate Status: $STATUS"
if [ "$STATUS" != "OK" ]; then
    echo "=== Failing Conditions ==="
    echo "$SONAR_STATUS" | jq -r '.projectStatus.conditions[] | select(.status != "OK") | "Metric: \(.metricKey) | Threshold: \(.errorThreshold) | Actual: \(.actualValue)"'
    
    echo "status=$STATUS" >> $GITHUB_OUTPUT
    echo "::error::Quality Gate failed with status: $STATUS"
    exit 1
fi

echo "status=$STATUS" >> $GITHUB_OUTPUT
echo "Quality Gate passed successfully!"
