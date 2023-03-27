resource "google_container_cluster" "mediamarkt-cloud" {
  name     = local.cluster_name
  location = local.region

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "mediamarkt-cloud" {
  name       = "${local.cluster_name}-node"
  location   = local.region
  cluster    = google_container_cluster.mediamarkt-cloud.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-small"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
