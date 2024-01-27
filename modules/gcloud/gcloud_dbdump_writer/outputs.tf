output "account_key" {
  value     = base64decode(google_service_account_key.dbdump_writer_key.private_key)
  sensitive = true
}

output "account_name" {
  value = google_service_account.dbdump_writer.email
}
