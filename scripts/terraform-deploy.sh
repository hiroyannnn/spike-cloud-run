#!/bin/bash

set -e

# Configuration
TERRAFORM_DIR="./terraform"

echo "🏗️  Starting Terraform deployment..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    exit 1
fi

# Change to terraform directory
cd ${TERRAFORM_DIR}

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning Terraform deployment..."
terraform plan

# Apply deployment (with confirmation)
echo "🚀 Applying Terraform configuration..."
echo "⚠️  This will create resources in GCP. Continue? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    terraform apply
    echo "✅ Terraform deployment completed successfully!"
    
    # Show outputs
    echo "📊 Terraform outputs:"
    terraform output
else
    echo "❌ Deployment cancelled."
    exit 1
fi