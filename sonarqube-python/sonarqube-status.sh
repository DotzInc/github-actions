#!/usr/bin/env bash

set -euo pipefail

SONAR_REPORT_TASK_FILE="${SONAR_REPORT_TASK_FILE:-.scannerwork/report-task.txt}"
SONAR_QG_TIMEOUT="${SONAR_QG_TIMEOUT:-300}"
SONAR_QG_POLL_INTERVAL="${SONAR_QG_POLL_INTERVAL:-5}"

analysis_id=""

normalize_host_url() {
    local host="$1"
    if [ -z "$host" ]; then
        echo "::error::SONAR_HOST_URL is empty. Set input sonar-host-url (e.g. https://sonarqube.example.com)."
        exit 1
    fi
    host="${host%/}"
    if [[ "$host" != http://* && "$host" != https://* ]]; then
        host="https://$host"
    fi
    echo "$host"
}

wait_for_analysis() {
    local start_ts
    start_ts=$(date +%s)

    echo "Waiting for SonarQube analysis to complete..."
    while true; do
        local now_ts elapsed task_response task_status
        now_ts=$(date +%s)
        elapsed=$((now_ts - start_ts))
        if [ "$elapsed" -ge "$SONAR_QG_TIMEOUT" ]; then
            echo "status=TIMEOUT" >> "$GITHUB_OUTPUT"
            echo "::error::Timeout waiting for SonarQube analysis after ${SONAR_QG_TIMEOUT}s"
            exit 1
        fi

        if ! task_response=$(curl -s -u "$SONAR_TOKEN:" "$1"); then
            echo "::error::Failed to reach SonarQube CE task URL: $1"
            exit 1
        fi
        task_status=$(echo "$task_response" | jq -r '.task.status // empty')

        if [ "$task_status" = "SUCCESS" ]; then
            analysis_id=$(echo "$task_response" | jq -r '.task.analysisId // empty')
            echo "SonarQube analysis finished successfully."
            break
        fi

        if [ "$task_status" = "FAILED" ] || [ "$task_status" = "CANCELED" ]; then
            echo "status=ERROR" >> "$GITHUB_OUTPUT"
            echo "::error::SonarQube analysis task ${task_status}"
            echo "$task_response" | jq -r '.task.errorMessage? // empty'
            exit 1
        fi

        sleep "$SONAR_QG_POLL_INTERVAL"
    done
}

SONAR_HOST_URL=$(normalize_host_url "${SONAR_HOST_URL:-}")

if [ -f "$SONAR_REPORT_TASK_FILE" ]; then
    CE_TASK_URL=$(grep -E '^ceTaskUrl=' "$SONAR_REPORT_TASK_FILE" | cut -d= -f2-)
    if [ -n "${CE_TASK_URL:-}" ]; then
        wait_for_analysis "$CE_TASK_URL"
    else
        echo "report-task.txt found but ceTaskUrl is missing; falling back to fixed wait."
        sleep 15
    fi
else
    echo "report-task.txt not found at $SONAR_REPORT_TASK_FILE; falling back to fixed wait."
    sleep 15
fi

if [ -n "$analysis_id" ]; then
    if ! SONAR_STATUS=$(curl -s -u "$SONAR_TOKEN:" \
    "$SONAR_HOST_URL/api/qualitygates/project_status?analysisId=$analysis_id"); then
        echo "::error::Failed to query Quality Gate status by analysisId."
        exit 1
    fi
else
    if [ -z "${SONAR_PROJECT_KEY:-}" ]; then
        echo "::error::SONAR_PROJECT_KEY is empty. Set input sonar-project-key."
        exit 1
    fi
    if ! SONAR_STATUS=$(curl -s -u "$SONAR_TOKEN:" \
    "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$SONAR_PROJECT_KEY"); then
        echo "::error::Failed to query Quality Gate status by projectKey."
        exit 1
    fi
fi

# Extract overall status
STATUS=$(echo "$SONAR_STATUS" | jq -r '.projectStatus.status // empty')

# Process failing conditions
echo "SonarQube Quality Gate Status: $STATUS"
if [ "$STATUS" != "OK" ]; then
    echo "=== Failing Conditions ==="
    echo "$SONAR_STATUS" | jq -r '.projectStatus.conditions[]? | select(.status != "OK") | "Metric: \(.metricKey) | Threshold: \(.errorThreshold) | Actual: \(.actualValue)"'
    
    echo "status=$STATUS" >> "$GITHUB_OUTPUT"
    echo "::error::Quality Gate failed with status: $STATUS"
    exit 1
fi

echo "status=$STATUS" >> "$GITHUB_OUTPUT"
echo "Quality Gate passed successfully!"
