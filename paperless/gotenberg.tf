
locals {
  gotenberg_labels = {
    name = "gotenberg"
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

