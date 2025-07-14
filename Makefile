# Makefile for spike-cloud-run

.PHONY: help install dev build test lint format clean docker-up docker-down terraform-init terraform-plan terraform-apply terraform-destroy

help: ## Show this help message
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development
install: ## Install dependencies
	npm install

dev: ## Start development server
	npm run dev

build: ## Build the application
	npm run build

test: ## Run tests
	npm test

lint: ## Run linter
	npm run lint

format: ## Format code
	npm run format

##@ Database
db-generate: ## Generate database migrations
	npm run db:generate

db-migrate: ## Run database migrations
	npm run db:migrate

db-migrate-prod: ## Run production database migrations via Cloud Run Job
	export PROJECT_ID=spike-cloud-run && ./scripts/run-migration.sh

db-studio: ## Open Drizzle Studio
	npm run db:studio

##@ Docker
docker-up: ## Start Docker containers
	docker-compose up -d

docker-down: ## Stop Docker containers
	docker-compose down

docker-dev: ## Start development Docker containers
	docker-compose -f docker-compose.dev.yml up -d

docker-logs: ## Show Docker logs
	docker-compose logs -f

docker-clean: ## Clean Docker containers and volumes
	docker-compose down -v
	docker system prune -f

##@ Terraform
terraform-init: ## Initialize Terraform
	cd terraform && terraform init

terraform-plan: ## Plan Terraform deployment
	cd terraform && terraform plan

terraform-apply: ## Apply Terraform configuration
	cd terraform && terraform apply

terraform-destroy: ## Destroy Terraform resources
	cd terraform && terraform destroy

##@ Deployment
deploy: ## Deploy application to Cloud Run
	./scripts/deploy.sh

terraform-deploy: ## Deploy infrastructure using Terraform
	./scripts/terraform-deploy.sh

##@ Cleanup
clean: ## Clean build artifacts
	rm -rf dist
	rm -rf node_modules
	rm -rf .drizzle