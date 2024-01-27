resource "google_sql_database_instance" "db" {
  name             = var.database_instance_name
  database_version = var.database_version
  region           = var.database_region

  lifecycle {
    prevent_destroy = true
  }

  settings {
    tier              = var.database_tier
    activation_policy = "ALWAYS"
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.database_private_network

      dynamic "authorized_networks" {
        for_each = [for s in var.authorized_networks : {
          name  = s.name
          value = s.value
        }]
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }

    maintenance_window {
      day  = 6
      hour = 22
    }

    disk_size = "50"
    disk_type = "PD_SSD"

    database_flags {
      name  = "log_output"
      value = "FILE"
    }
    database_flags {
      name  = "slow_query_log"
      value = "on"
    }

    # switch query logging on
    #    database_flags {
    #      name  = "general_log"
    #      value = "on"
    #    }
  }
}

resource "google_sql_user" "default_user" {
  name     = var.database_username_default
  instance = google_sql_database_instance.db.name
  host     = "%"
  password = var.database_password_default
}

resource "google_sql_user" "readonly_user" {
  name     = var.database_username_readonly
  instance = google_sql_database_instance.db.name
  host     = "%"
  password = var.database_password_readonly
}

resource "google_sql_database" "serlo_database" {
  name      = var.database_name
  instance  = google_sql_database_instance.db.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_520_ci"
}
