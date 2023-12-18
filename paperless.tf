resource "kubernetes_namespace" "paperless" {
  metadata {
    name = "paperless"
  }
}

module "paperless" {
  source = "./paperless"

  namespace     = kubernetes_namespace.paperless.metadata[0].name
  paperless_url = "https://paperless.d-jensen.de"
}

