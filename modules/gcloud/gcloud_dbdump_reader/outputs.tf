output "account_key" {
  value     = base64decode(google_service_account_key.dbdump_reader_key.private_key)
  sensitive = true
}

output "account_name" {
  value = google_service_account.dbdump_reader.email
}
