resource "google_artifact_registry_repository" "mediamarkt-cloud" {
  location      = local.region
  repository_id = local.cluster_name
  format        = "DOCKER"
}
