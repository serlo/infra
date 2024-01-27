output "database_private_ip_address" {
  value = google_sql_database_instance.db.private_ip_address
}
