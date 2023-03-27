output "service" {
  value = "http://${kubernetes_service_v1.mms-cloud-skeleton.status.0.load_balancer.0.ingress.0.ip}"
}
