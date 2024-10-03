#!/usr/bin/env bash

# Set the default bucket name
BUCKET_NAME="${BUCKET_NAME:-gcs-test-"$(date '+%Y%m%d%H%M%S')"}"

# Check if gsutil command exists
if ! command -v gsutil &> /dev/null; then
    echo "Error: gsutil command not found. Please install Google Cloud SDK."
    exit 1
fi

# Create the GCS bucket
echo "Creating GCS bucket: gs://${BUCKET_NAME}/"
gsutil mb gs://${BUCKET_NAME}/

# Create the lifecycle configuration JSON file
LIFECYCLE_FILE="lifecycle_policy.json"

# Set the lifecycle policy on the bucket using the separate file
echo "Setting lifecycle policy for bucket: gs://${BUCKET_NAME}/"
gsutil lifecycle set ${LIFECYCLE_FILE} gs://${BUCKET_NAME}/

