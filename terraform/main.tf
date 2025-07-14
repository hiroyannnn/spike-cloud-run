terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "cloud_run_api" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "cloud_sql_api" {
  project = var.project_id
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "vpc_access_api" {
  project = var.project_id
  service = "vpcaccess.googleapis.com"
}

resource "google_project_service" "secret_manager_api" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "container_registry_api" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
}

# Cloud SQL Instance
resource "google_sql_database_instance" "postgres" {
  name             = "${var.project_name}-postgres"
  database_version = "POSTGRES_17"
  region           = var.region

  depends_on = [
    google_project_service.cloud_sql_api,
    google_service_networking_connection.private_service_connection
  ]

  settings {
    tier = "db-f1-micro"

    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.self_link
    }
  }

  deletion_protection = false
}

# Cloud SQL Database
resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.postgres.name
}

# Cloud SQL User
resource "google_sql_user" "user" {
  name     = var.database_user
  instance = google_sql_database_instance.postgres.name
  password = var.database_password
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.name
}

# Private Service Connection
resource "google_compute_global_address" "private_service_connection" {
  name          = "${var.project_name}-private-service-connection"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_connection.name]
}

# VPC Access Connector
resource "google_vpc_access_connector" "connector" {
  name          = "${var.project_name}-connector"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
  region        = var.region

  depends_on = [google_project_service.vpc_access_api]
}

# Service Account for Cloud Run
resource "google_service_account" "cloud_run_service_account" {
  account_id   = "${var.project_name}-cloud-run-sa"
  display_name = "Cloud Run Service Account"
  description  = "Service account for Cloud Run application"
}

# IAM Role for Cloud SQL Client
resource "google_project_iam_member" "cloud_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run_service_account.email}"
}

# IAM Role for Secret Manager Secret Accessor
resource "google_project_iam_member" "secret_manager_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run_service_account.email}"
}

# Secret Manager Secret for Database URL
resource "google_secret_manager_secret" "database_url" {
  secret_id = "database-url"

  depends_on = [google_project_service.secret_manager_api]

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_url_version" {
  secret      = google_secret_manager_secret.database_url.id
  secret_data = "postgresql://${google_sql_user.user.name}:${google_sql_user.user.password}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.database.name}"
}

# Cloud Run Service
resource "google_cloud_run_service" "app" {
  name     = var.project_name
  location = var.region

  depends_on = [
    google_project_service.cloud_run_api,
    google_secret_manager_secret_version.database_url_version
  ]

  template {
    spec {
      service_account_name = google_service_account.cloud_run_service_account.email

      containers {
        image = "gcr.io/${var.project_id}/${var.project_name}:latest"

        env {
          name = "DATABASE_URL"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.database_url.secret_id
              key  = "latest"
            }
          }
        }

        env {
          name  = "NODE_ENV"
          value = "production"
        }

        ports {
          container_port = 8080
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "10"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/client-name"          = "terraform"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# IAM Policy for Cloud Run Service (Allow public access)
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.app.name
  location = google_cloud_run_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
