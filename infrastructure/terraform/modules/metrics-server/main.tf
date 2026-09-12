resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.13.0"

  wait    = true
  atomic  = true
  timeout = 600

  values = [
    yamlencode({
      replicas = 2

      resources = {
        requests = {
          cpu    = "100m"
          memory = "200Mi"
        }

        limits = {
          cpu    = "500m"
          memory = "500Mi"
        }
      }
    })
  ]
}