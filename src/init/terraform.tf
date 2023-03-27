terraform {
  required_version = "~> 1.4.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.58.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

provider "google" {
  project = "apMXLT6gsS96qVMj7T3S7eExYnZ6ub"
}
