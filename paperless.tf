resource "kubernetes_namespace" "paperless" {
  metadata {
    name = "paperless"
  }
}
