terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.5.0" # Specify the version you want to use
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3" # Specify the version you want to use
    }
  }

  # NOTE: terraform version in my laptop
  # you can specify the newer one.
  required_version = ">= 1.5.7"
}

locals {
  source_code_path = var.source_code_path == "" ? "${path.module}/src" : var.source_code_path
}

# GCS Bucket name need to be globally unique,
# so we add a random suffix to specified name
resource "random_string" "gcs_name_suffix" {
  length  = 7
  special = false
  numeric = false
  upper   = false
}

# GCS Bucket for static content
resource "google_storage_bucket" "static_site_bucket" {
  name     = "${var.bucket_name}-${random_string.gcs_name_suffix.result}"
  project  = var.project_id
  location = var.region
}

data "google_compute_default_service_account" "default" {
  project = var.project_id
}

# assign permission to view object in GCS, so that GCE can use this service account for copying source code from GCS -> its disk (see below)
resource "google_project_iam_member" "gce_default_storage_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

# Upload all files from the static-html folder to GCS bucket
resource "google_storage_bucket_object" "static_html_files" {
  for_each = fileset(local.source_code_path, "**")
  name     = each.value
  bucket   = google_storage_bucket.static_site_bucket.name
  source   = "${path.module}/src/${each.value}"
}

# Create GCP Instance Template (with startup script to copy index.html from GCS)
resource "google_compute_instance_template" "web_app_template" {
  # NOTE: VM specs are hard-coded for demo purpose only.

  name         = "web-app-template"
  project      = var.project_id
  machine_type = "e2-medium"

  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/debian-cloud/global/images/family/debian-11"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  # grant GCE instance permission to copy source code from GCS -> apache html directory
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only"]
  }

  # Metadata startup script to deploy a static HTML
  metadata_startup_script = <<-EOT
    sudo apt-get update
    sudo apt-get install -y apache2

    # -m for parallel copy
    # wildcard for copy all files, put it directly to /var/www/html, instead of in a subdirectory
    sudo gsutil -m cp -r "gs://${google_storage_bucket.static_site_bucket.name}/*" /var/www/html/

    # show VM hostname in homepage, continue startup script even if this failed.
    HOSTNAME=$(hostname)
    echo "HOSTNAME: $HOSTNAME" >> /var/www/html/index.html || true

    sudo systemctl restart apache2
  EOT

  tags = ["web"]
}

# Create Managed Instance Group with Autoscaling
resource "google_compute_instance_group_manager" "web_app_group" {
  name               = "web-app-group"
  base_instance_name = "web-app"
  project            = var.project_id
  zone               = var.autoscaler_zone

  version {
    instance_template = google_compute_instance_template.web_app_template.self_link
  }

  target_size = var.min_replicas

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http.self_link
    initial_delay_sec = 300
  }
}

# Autoscaler
resource "google_compute_autoscaler" "web_app_autoscaler" {
  name    = "web-app-autoscaler"
  project = var.project_id
  zone    = var.autoscaler_zone
  target  = google_compute_instance_group_manager.web_app_group.id

  autoscaling_policy {
    max_replicas = var.max_replicas
    min_replicas = var.min_replicas

    cpu_utilization {
      target = 0.9
    }
  }
}

# Create HTTP Load Balancer
resource "google_compute_backend_service" "web_app_backend" {
  name                  = "web-app-backend"
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.http.id]
  backend {
    group = google_compute_instance_group_manager.web_app_group.instance_group
  }

  depends_on = [google_compute_health_check.http]
}

resource "google_compute_url_map" "web_app_url_map" {
  name            = "web-app-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.web_app_backend.self_link
}

resource "google_compute_target_http_proxy" "web_app_proxy" {
  name    = "web-app-proxy"
  project = var.project_id
  url_map = google_compute_url_map.web_app_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "web_app_forwarding_rule" {
  name       = "web-app-forwarding-rule"
  project    = var.project_id
  target     = google_compute_target_http_proxy.web_app_proxy.self_link
  port_range = "80"
}

# Health check
resource "google_compute_health_check" "http" {
  name                = "web-app-http-health-check"
  project             = var.project_id
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

# Firewall rule to allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
