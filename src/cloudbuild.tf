data "google_project" "project" {}

# =========================================================
# This resource cannot be applied because not if the user
# that the Nuwe team gave us has sufficient permissions
# =========================================================
#
# resource "google_project_iam_member" "cloudbuild-kubernetes" {
#   project = local.project
#   role    = "roles/container.developer"
#   member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
# }

resource "google_cloudbuild_trigger" "mms-cloud-skeleton" {
  location = local.region
  name     = local.repository_name
  project  = local.project

  github {
    owner = "mvochoa"
    name  = local.repository_name
    push {
      branch = "^main$"
    }
  }

  build {

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", local.docker_image_name, "."]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["tag", local.docker_image_name, "${local.docker_image_base}:latest"]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", local.docker_image_name]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${local.docker_image_base}:latest"]
    }

    # ===========================================================
    # The following steps cannot be executed since the necessary
    # role can be applied to the cloud build because the user
    # that the Nuwe team gave us has sufficient permissions.
    # ===========================================================
    #
    # step {
    #   name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
    #   entrypoint = "gcloud"
    #   args       = ["container", "clusters", "get-credentials", local.cluster_name, "--region=${local.region}", "--project=${local.project}"]
    # }

    # step {
    #   name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
    #   entrypoint = "kubectl"
    #   args       = ["set", "image", "deployment/${local.repository_name}", "${local.repository_name}=${local.docker_image_name}"]
    # }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
  }

  depends_on = [
    google_container_cluster.mediamarkt-cloud,
    kubernetes_deployment_v1.mms-cloud-skeleton,
    google_artifact_registry_repository.mediamarkt-cloud
  ]
}
