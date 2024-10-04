terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.5.0" # Specify the version you want to use
    }
  }

  # NOTE: terraform version in my laptop
  # you can specify the newer one.
  required_version = ">= 1.5.7"
}


locals {
  # put this to local for easily update convention later
  prefix = var.prefix
}


resource "google_compute_network" "vpc_network" {
  name                    = "${local.prefix}-vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${local.prefix}-subnet"
  ip_cidr_range = var.ip_cidr_range
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc_network.name

  private_ip_google_access = true
}

resource "google_compute_address" "static_ip" {
  name    = "${local.prefix}-static-ip"
  project = var.project_id
  region  = var.region
}

resource "google_compute_router" "router" {
  name    = "${local.prefix}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc_network.name

  bgp {
    # Private ASNs typically range from 64512 to 65535 
    # and can be used freely without registration with a regional internet registry (RIR)
    # we pick 65001 to intend that this network should not be advertised on internet
    asn = 65001
  }
}

resource "google_compute_router_nat" "nat" {
  name    = "${local.prefix}-nat"
  project = var.project_id
  region  = var.region
  router  = google_compute_router.router.name

  nat_ip_allocate_option             = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  nat_ips = [google_compute_address.static_ip.name]
}
