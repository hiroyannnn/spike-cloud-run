#!/bin/bash

set -e

# Configuration
PROJECT_ID=${PROJECT_ID:-"your-gcp-project-id"}
REGION=${REGION:-"asia-northeast1"}
SERVICE_NAME=${SERVICE_NAME:-"spike-cloud-run"}
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "🚀 Starting deployment process..."

# Check if required tools are installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install it first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install it first."
    exit 1
fi

# Authenticate with gcloud
echo "🔐 Authenticating with gcloud..."
gcloud auth configure-docker

# Build and push Docker image
echo "🏗️  Building Docker image..."
docker build --platform linux/amd64 -t ${IMAGE_NAME}:latest .

echo "📤 Pushing Docker image to Container Registry..."
docker push ${IMAGE_NAME}:latest

echo "☁️  Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME}:latest \
    --region ${REGION} \
    --platform managed \
    --allow-unauthenticated \
    --set-env-vars NODE_ENV=production \
    --max-instances 10 \
    --memory 512Mi \
    --cpu 1 \
    --port 8080 \
    --timeout 300

echo "✅ Deployment completed successfully!"

# Get the service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)')
echo "🌐 Service URL: ${SERVICE_URL}"
echo "🔍 Health check: ${SERVICE_URL}/health"