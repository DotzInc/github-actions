#!/usr/bin/env bash
set -euo pipefail

# Resolve project ID: prefer input, else gcloud config
PROJECT_ID_RESOLVED="${PROJECT_ID:-}"
if [[ -z "$PROJECT_ID_RESOLVED" ]]; then
  PROJECT_ID_RESOLVED="$(gcloud config get-value project 2>/dev/null || true)"
fi

if [[ -z "$PROJECT_ID_RESOLVED" || "$PROJECT_ID_RESOLVED" == "(unset)" ]]; then
  echo "Could not determine GCP project from gcloud config. Ensure auth step set the project, or pass project_id input."
  exit 1
fi

if [[ -z "${GCP_REGION:-}" ]]; then
  echo "Input gcp_region is required"
  exit 1
fi

if [[ -z "${REPOSITORY_NAME:-}" ]]; then
  echo "Input repository_name is required"
  exit 1
fi

if [[ -z "${TAG_VERSION:-}" ]]; then
  echo "Input tag_version is required"
  exit 1
fi

IMAGE_URL="${GCP_REGION}-docker.pkg.dev/${PROJECT_ID_RESOLVED}/${PROJECT_ID_RESOLVED}/${REPOSITORY_NAME}:${GITHUB_SHA}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Baking ELASTIC_APM_SERVICE_VERSION into image: $IMAGE_URL"

# Build a tiny wrapper image setting ELASTIC_APM_SERVICE_VERSION, using the resolved base image
cat > "$TMPDIR/Dockerfile" << EOF
FROM ${IMAGE_URL}
ENV ELASTIC_APM_SERVICE_VERSION=${TAG_VERSION}
EOF

# Build and push to the same tag so Terraform deploys this exact image
gcloud builds submit --tag "$IMAGE_URL" "$TMPDIR"

echo "Successfully built and pushed: $IMAGE_URL"

