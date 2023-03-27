resource "kubernetes_config_map_v1" "continuous-delivery" {
  metadata {
    name = "script-continuous-delivery"
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

TAG=$(GetTag)
IMAGE=$(kubectl get deployment ${local.repository_name} -o=jsonpath='{.spec.template.spec.containers[0].image}')

if [[ "$IMAGE" != "${local.docker_image_base}:$TAG" ]];
then
  kubectl set image deployment/${local.repository_name} ${local.repository_name}=${local.docker_image_base}:$TAG
fi

EOF
  }
}


resource "kubernetes_cron_job_v1" "continuous-delivery" {
  metadata {
    name = "continuous-delivery"
  }

  spec {
    schedule = "*/5 * * * *"

    job_template {
      metadata {}

      spec {
        backoff_limit = 0

        template {
          metadata {}

          spec {
            container {
              image = "gcr.io/google.com/cloudsdktool/cloud-sdk:latest"
              name  = "continuous-delivery"

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
                name = "script-continuous-delivery"
                items {
                  key  = "script"
                  path = "script.sh"
                }
              }
            }
          }
        }
      }
    }
  }
}
