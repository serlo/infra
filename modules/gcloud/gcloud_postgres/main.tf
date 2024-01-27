resource "google_sql_database_instance" "db" {
  name             = var.database_instance_name
  database_version = "POSTGRES_9_6"
  region           = var.database_region

  lifecycle {
    prevent_destroy = false
  }

  settings {
    tier              = var.database_tier
    activation_policy = "ALWAYS"
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.database_private_network
    }

    backup_configuration {
      enabled  = true
      location = "eu"
    }

    maintenance_window {
      day  = 6
      hour = 22
    }

    disk_size = "10"
    disk_type = "PD_SSD"
  }
}

# postgres needs also a default user postgres
resource "google_sql_user" "users_postgres" {
  name     = "postgres"
  instance = google_sql_database_instance.db.name
  #host     = "%"
  password = var.database_password_postgres
}

resource "google_sql_user" "users_default" {
  name     = var.database_username_default
  instance = google_sql_database_instance.db.name
  #host     = "%"
  password = var.database_password_default
}

resource "google_sql_user" "users_readonly" {
  name     = var.database_username_readonly
  instance = google_sql_database_instance.db.name
  #host     = "%"
  password = var.database_password_readonly
}

resource "google_sql_database" "database" {
  count     = length(var.database_names)
  name      = var.database_names[count.index]
  instance  = google_sql_database_instance.db.name
  charset   = "UTF8"
  collation = "en_US.UTF8"
}
