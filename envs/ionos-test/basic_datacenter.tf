resource "ionoscloud_ipblock" "serlo_ipblock" {
  location = ionoscloud_datacenter.serlo_datacenter.location
  size     = 1
  name     = "serlo_ipblock"
}

resource "ionoscloud_nic" "public_nic" {
  server_id       = ionoscloud_server.lti_tool_server.id
  datacenter_id   = ionoscloud_datacenter.serlo_datacenter.id
  lan             = ionoscloud_lan.serlo_uplink.id
  name            = "nic_public"
  dhcp            = true
  firewall_active = false
  ips             = [ionoscloud_ipblock.serlo_ipblock.ips[0]]
}

resource "ionoscloud_datacenter" "serlo_datacenter" {
  name     = "serlo_datacenter"
  location = "de/txl"
}

resource "ionoscloud_lan" "serlo_uplink" {
  datacenter_id = ionoscloud_datacenter.serlo_datacenter.id
  public        = true
  name          = "serlo_uplink"
}

data "ionoscloud_image" "lti_tool" {
  type        = "HDD"
  cloud_init  = "V1"
  image_alias = "ubuntu:latest"
  location    = "us/las"
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
  }
  nic {
    lan  = ionoscloud_lan.serlo_uplink.id
    name = "system"
    dhcp = true
  }
}

resource "ionoscloud_lan" "serlo_lan" {
  datacenter_id = ionoscloud_datacenter.serlo_datacenter.id
  public        = false
  name          = "serlo_lan"
}

resource "ionoscloud_mongo_cluster" "serlo_mongo_cluster" {
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
