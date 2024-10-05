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

terraform {
  backend "gcs" {
    bucket  = "tfstate-20241006" # TODO: replace this with your bucket name
    prefix  = "tfstate/"
  }
}


# this is to test if tfstate is stored in GCS bucket properly
resource "random_string" "gcs_name_suffix" {
  length  = 7
  special = false
  numeric = false
  upper   = false
}
