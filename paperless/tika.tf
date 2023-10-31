locals {
  tika_labels = {
    name = "tika"
  }
}

resource "kubernetes_service" "tika" {
  metadata {
    name      = local.tika_labels.name
    namespace = var.namespace
  }

  spec {
    port {
      port        = 9998
      target_port = "9998"
    }

    selector = local.tika_labels
  }
}

resource "kubernetes_deployment" "tika" {
  metadata {
    name      = local.tika_labels.name
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.tika_labels
    }

    template {
      metadata {
        labels = local.tika_labels
      }

      spec {
        container {
          name  = "tika"
          image = "ghcr.io/paperless-ngx/tika:latest"
        }

        restart_policy = "Always"
      }
    }
  }
}

