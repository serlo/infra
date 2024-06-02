locals {
  domain  = "serlo-staging.dev"
  project = "serlo-staging"

  credentials_path = "secrets/serlo-staging-terraform-15240e38ec22.json"
  service_account  = "terraform@serlo-staging.iam.gserviceaccount.com"

  region = "europe-west3"
  zone   = "europe-west3-a"

  cluster_machine_type = "n1-highcpu-2"

  mysql_database_instance_name = "${local.project}-mysql-2021-07-15"
  kpi_database_instance_name   = "${local.project}-postgres-2020-01-19-3"

  postgres_database_username_default  = "serlo"
  postgres_database_username_readonly = "serlo_readonly"
}

module "cluster" {
  source   = "../../modules/gcloud/cluster"
  name     = "${local.project}-cluster"
  project  = local.project
  location = local.zone
  region   = local.region

  node_pools = {
    preemptible = {
      machine_type       = local.cluster_machine_type
      preemptible        = true
      initial_node_count = 2
      min_node_count     = 2
      max_node_count     = 10
      location_policy    = "ANY"
    }
    non-preemptible = {
      machine_type       = local.cluster_machine_type
      preemptible        = false
      initial_node_count = 0
      min_node_count     = 0
      max_node_count     = 10
      location_policy    = "BALANCED"
    }
  }
}

module "mysql" {
  source                     = "../../modules/gcloud/gcloud_mysql"
  database_instance_name     = local.mysql_database_instance_name
  database_version           = "MYSQL_8_0_31"
  database_connection_name   = "${local.project}:${local.region}:${local.mysql_database_instance_name}"
  database_region            = local.region
  database_name              = "serlo"
  database_tier              = "db-n1-standard-1"
  database_private_network   = module.cluster.network
  database_password_default  = var.athene2_database_password_default
  database_password_readonly = var.athene2_database_password_readonly
}

module "gcloud_postgres" {
  source                   = "../../modules/gcloud/gcloud_postgres"
  database_instance_name   = local.kpi_database_instance_name
  database_connection_name = "${local.project}:${local.region}:${local.kpi_database_instance_name}"
  database_region          = local.region
  database_names           = ["kpi", "hydra"]
  database_private_network = module.cluster.network

  database_password_postgres = var.kpi_kpi_database_password_postgres
  database_username_default  = local.postgres_database_username_default
  database_password_default  = var.kpi_kpi_database_password_default
  database_username_readonly = local.postgres_database_username_readonly
  database_password_readonly = var.kpi_kpi_database_password_readonly
}

module "athene2_dbsetup" {
  source    = "../../modules/dbsetup"
  image     = "eu.gcr.io/serlo-shared/athene2-dbsetup-cronjob:3.1.1"
  namespace = kubernetes_namespace.api_namespace.metadata.0.name
  node_pool = module.cluster.node_pools.preemptible
  schedule  = "0 2 * * *"
  mysql = {
    host     = module.mysql.database_private_ip_address
    username = "serlo"
    password = var.athene2_database_password_default
  }
  postgres = {
    host     = module.gcloud_postgres.database_private_ip_address
    password = var.kpi_kpi_database_password_default
  }
  bucket = {
    url                  = "gs://anonymous-data"
    service_account_key  = module.gcloud_dbdump_reader.account_key
    service_account_name = module.gcloud_dbdump_reader.account_name
  }
}

module "gcloud_dbdump_reader" {
  source = "../../modules/gcloud/gcloud_dbdump_reader"
}

module "ingress-nginx" {
  source = "../../modules/ingress-nginx"

  node_pool = module.cluster.node_pools.non-preemptible
  ip        = module.cluster.address
}

module "cloudflare" {
  source  = "../../modules/cloudflare"
  domain  = local.domain
  ip      = module.cluster.address
  zone_id = "0067b08b108fbcf88ddaeaae4ac3d6ac"
}
