
locals {
  gotenberg_labels = {
    name = "gotenberg"
  }
}

resource "kubernetes_service" "gotenburg" {
  metadata {
    name      = local.gotenberg_labels.name
    namespace = var.namespace
  }

  spec {
    port {
      port        = 9998
      target_port = "9998"
    }

    selector = local.gotenberg_labels
  }
}

resource "kubernetes_deployment" "gotenberg" {
  metadata {
    name      = local.gotenberg_labels.name
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.gotenberg_labels
    }

    template {
      metadata {
        labels = local.gotenberg_labels
      }

      spec {
        container {
          name  = "gotenberg"
          image = "docker.io/gotenberg/gotenberg:7.8"
          args  = ["gotenberg", "--chromium-disable-javascript=true", "--chromium-allow-list=file:///tmp/.*"]
        }

        restart_policy = "Always"
      }
    }
  }
}

