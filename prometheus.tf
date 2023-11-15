resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.6.0"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name

  values = [yamlencode({
    server = {
      persistentVolume = {
        size = "20Gi"
      }
    }
  })]
}

