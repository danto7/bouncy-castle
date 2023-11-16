resource "kubernetes_namespace" "jellyfin" {
  metadata {
    name = "jellyfin"
  }
}

module "jellyfin" {
  source = "./kube-app"

  name      = "jellyfin"
  namespace = kubernetes_namespace.jellyfin.metadata[0].name
  image     = "jellyfin/jellyfin:stable"
  volumes = {
    config = {
      container_path = "/config"
      size           = "1Gi"
    }
    cache = {
      container_path = "/cache"
      size           = "2Gi"
    }
  }
}
