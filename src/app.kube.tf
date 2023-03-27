resource "kubernetes_deployment_v1" "mms-cloud-skeleton" {
  metadata {
    name = local.repository_name
    labels = {
      app = local.repository_name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = local.repository_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.repository_name
        }
      }

      spec {

        container {
          image = "${local.docker_image_base}:latest"
          name  = local.repository_name

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
          }
        }

      }
    }
  }

  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      spec.0.template.0.spec.0.container.0.image
    ]
  }
}

resource "kubernetes_service_v1" "mms-cloud-skeleton" {
  metadata {
    name = local.repository_name
  }

  spec {
    selector = {
      app = local.repository_name
    }

    port {
      port        = 80
      target_port = 3000
    }

    session_affinity = "ClientIP"
    type             = "LoadBalancer"
  }
}

