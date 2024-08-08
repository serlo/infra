terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "6.5.0"
    }
  }
}

provider "ionoscloud" {
  # Configuration options
}

resource "ionoscloud_datacenter" "serlo_datacenter" {
  name     = "serlo_datacenter"
  location = "de/txl"
}

resource "ionoscloud_lan" "serlo_lan" {
  datacenter_id = ionoscloud_datacenter.serlo_datacenter.id
  public        = false
  name          = "serlo_lan"
}

resource "ionoscloud_mongo_cluster" "serlo_mongo_cluster" {
  maintenance_window {
    day_of_the_week = "Sunday"
    time            = "09:00:00"
  }
  mongodb_version = "5.0"
  instances       = 1
  display_name    = "serlo_mongo_cluster"
  location        = ionoscloud_datacenter.serlo_datacenter.location
  connections {
    datacenter_id = ionoscloud_datacenter.serlo_datacenter.id
    lan_id        = ionoscloud_lan.serlo_lan.id
    cidr_list     = ["192.168.1.108/24"]
  }
  template_id = "6b78ea06-ee0e-4689-998c-fc9c46e781f6"
}

resource "random_password" "cluster_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
