#!/bin/bash

set -e

PROJECT_ID=${PROJECT_ID:-"spike-cloud-run"}
REGION=${REGION:-"asia-northeast1"}
JOB_NAME="spike-cloud-run-migrate"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${JOB_NAME}"

echo "🚀 Building migration Docker image..."
docker build --platform linux/amd64 -f Dockerfile.migrate -t ${IMAGE_NAME}:latest .

echo "📤 Pushing migration image..."
docker push ${IMAGE_NAME}:latest

echo "🔄 Creating or updating migration job..."
gcloud run jobs replace ${JOB_NAME} \
    --image=${IMAGE_NAME}:latest \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --set-secrets="DATABASE_URL=database-url:latest" \
    --vpc-connector=spike-cloud-run-connector \
    --vpc-egress=private-ranges-only \
    --service-account=spike-cloud-run-cloud-run-sa@${PROJECT_ID}.iam.gserviceaccount.com \
    --max-retries=1 \
    --memory=512Mi \
    --cpu=1 \
    --task-timeout=300 2>/dev/null || \
gcloud run jobs create ${JOB_NAME} \
    --image=${IMAGE_NAME}:latest \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --set-secrets="DATABASE_URL=database-url:latest" \
    --vpc-connector=spike-cloud-run-connector \
    --vpc-egress=private-ranges-only \
    --service-account=spike-cloud-run-cloud-run-sa@${PROJECT_ID}.iam.gserviceaccount.com \
    --max-retries=1 \
    --memory=512Mi \
    --cpu=1 \
    --task-timeout=300

echo "▶️  Executing migration job..."
gcloud run jobs execute ${JOB_NAME} \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --wait

echo "✅ Migration completed!"