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
  public        = true
  name          = "serlo_lan"
}

data "ionoscloud_image" "lti_tool" {
  type        = "HDD"
  cloud_init  = "V1"
  image_alias = "ubuntu:latest"
  # image_alias           = "eu.gcr.io/serlo-shared/editor-as-lti-tool"
  location = "us/las"
}

resource "ionoscloud_ipblock" "ipblock" {
  location = ionoscloud_datacenter.serlo_datacenter.location
  size     = 1
  name     = "IP Block Example"
}

resource "ionoscloud_server" "lti_tool_server" {
  name              = "Server Example"
  datacenter_id     = ionoscloud_datacenter.serlo_datacenter.id
  availability_zone = "AUTO"
  image_name        = data.ionoscloud_image.lti_tool.name
  image_password    = "12345678"
  cores             = 1
  ram               = 1024
  volume {
    name      = "system"
    size      = 5
    disk_type = "SSD Standard"
    # user_data         = "foo"
    # bus               = "VIRTIO"
    # availability_zone = "AUTO"
  }
  nic {
    lan             = ionoscloud_lan.serlo_lan.id
    name            = "system"
    dhcp            = true
    firewall_active = true
    firewall_type   = "BIDIRECTIONAL"
    ips             = [ionoscloud_ipblock.ipblock.ips[0]]
    firewall {
      protocol         = "TCP"
      name             = "SSH"
      port_range_start = 22
      port_range_end   = 22
      source_mac       = "00:0a:95:9d:68:17"
      # source_ip         = ionoscloud_ipblock.ipblock.ips[2]
      # target_ip         = ionoscloud_ipblock.ipblock.ips[3]
      type = "EGRESS"
    }
  }
}

# resource "ionoscloud_mongo_cluster" "serlo_mongo_cluster" {
#   maintenance_window {
#     day_of_the_week = "Sunday"
#     time            = "09:00:00"
#   }
#   mongodb_version = "5.0"
#   instances       = 1
#   display_name    = "serlo_mongo_cluster"
#   location        = ionoscloud_datacenter.serlo_datacenter.location
#   connections {
#     datacenter_id = ionoscloud_datacenter.serlo_datacenter.id
#     lan_id        = ionoscloud_lan.serlo_lan.id
#     cidr_list     = ["192.168.1.108/24"]
#   }
#   template_id = "6b78ea06-ee0e-4689-998c-fc9c46e781f6"
# }

# resource "random_password" "server_password" {
#   length           = 16
# }
