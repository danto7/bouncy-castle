resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}
resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.4.2"
  namespace  = kubernetes_namespace.longhorn.metadata[0].name
}
