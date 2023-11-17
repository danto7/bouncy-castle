resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb"
  }
}
resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.12"
  namespace  = kubernetes_namespace.metallb.metadata[0].name

  values = [yamlencode({
    prometheus = {
      scrapeAnnotations = true
      rbacPrometheus    = false
    }
  })]
}

