terraform {

  backend "gcs" {
    bucket = "08fe34899c02123a-tfstate"
    prefix = "mediamarkt"
  }

  required_version = "~> 1.4.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.58.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }
  }
}

provider "google" {
  project = local.project
  region  = local.region
}

data "google_client_config" "default" {
  depends_on = [
    google_container_cluster.mediamarkt-cloud,
    google_container_node_pool.mediamarkt-cloud
  ]
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.mediamarkt-cloud.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.mediamarkt-cloud.master_auth.0.cluster_ca_certificate)
}
