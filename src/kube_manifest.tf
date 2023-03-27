resource "kubernetes_config_map_v1" "script" {
  metadata {
    name = "script-force-update-image"
  }

  data = {
    script = <<EOF
#!/bin/bash

function GetTag() {
  TAG=$(gcloud artifacts docker images list --include-tags europe-west1-docker.pkg.dev/apmxlt6gss96qvmj7t3s7eexynz6ub/mediamarkt-cloud/mms-cloud-skeleton | grep latest | awk '{printf $3$4}')
  TAG="$${TAG/latest/}"
  TAG="$${TAG/,/}"
  printf $TAG
}

gcloud container clusters get-credentials ${local.cluster_name} --region=${local.region} --project=${local.project}

IMAGE=$(kubectl get deployment ${local.repository_name} -o=jsonpath='{.spec.template.spec.containers[0].image}')

while true
do
  TAG=$(GetTag)

  if [[ "$IMAGE" != "${local.docker_image_base}:$TAG" ]];
  then
    kubectl set image deployment/${local.repository_name} ${local.repository_name}=${local.docker_image_base}:$TAG
  fi

  sleep 300
done

EOF
  }
}


resource "kubernetes_deployment_v1" "mms-cloud-skeleton" {
  metadata {
    name = local.repository_name
    labels = {
      app = local.repository_name
    }
  }

  spec {
    replicas = 1

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

        container {
          image = "gcr.io/google.com/cloudsdktool/cloud-sdk:latest"
          name  = "force-update-image"

          command = [
            "bash",
            "/root/script.sh",
          ]

          volume_mount {
            name       = "script-volume"
            mount_path = "/root/script.sh"
            sub_path   = "script.sh"
          }
        }

        volume {
          name = "script-volume"

          config_map {
            name = "script-force-update-image"
            items {
              key  = "script"
              path = "script.sh"
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

