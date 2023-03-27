locals {
  region          = "europe-west1"
  project         = "apmxlt6gss96qvmj7t3s7eexynz6ub"
  repository_name = "mms-cloud-skeleton"
  cluster_name    = "mediamarkt-cloud"

  docker_image_base = "${google_artifact_registry_repository.mediamarkt-cloud.location}-docker.pkg.dev/${google_artifact_registry_repository.mediamarkt-cloud.project}/${google_artifact_registry_repository.mediamarkt-cloud.name}/${local.repository_name}"
  docker_image_name = "${local.docker_image_base}:$SHORT_SHA"
}
