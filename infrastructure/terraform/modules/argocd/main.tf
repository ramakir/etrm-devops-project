resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.1.0"

  create_namespace = true

  wait    = true
  atomic  = true
  timeout = 600
}
