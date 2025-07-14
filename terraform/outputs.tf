output "cloud_run_url" {
  description = "The URL of the Cloud Run service"
  value       = google_cloud_run_service.app.status[0].url
}

output "cloud_sql_instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.name
}

output "cloud_sql_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.connection_name
}

output "cloud_sql_private_ip" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "database_url_secret_name" {
  description = "The name of the Secret Manager secret containing the database URL"
  value       = google_secret_manager_secret.database_url.secret_id
}

output "service_account_email" {
  description = "The email of the Cloud Run service account"
  value       = google_service_account.cloud_run_service_account.email
}

output "vpc_connector_name" {
  description = "The name of the VPC Access Connector"
  value       = google_vpc_access_connector.connector.name
}