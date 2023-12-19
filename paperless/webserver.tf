locals {
  webserver_labels = {
    name = "webserver"
  }
  webserver_pvs = { for key, value in local.pvs : key => value if value.deployment == "webserver" }
}

resource "kubernetes_service" "webserver" {
  metadata {
    name      = local.webserver_labels.name
    namespace = var.namespace
  }

  spec {
    port {
      port        = 80
      target_port = "8000"
    }

    selector = local.webserver_labels
  }
}

output "endpoint" {
  value = "http://${kubernetes_service.webserver.metadata[0].name}.${var.namespace}.svc.cluster.local"
}

resource "kubernetes_deployment" "webserver" {
  metadata {
    name      = local.webserver_labels.name
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.webserver_labels
    }

    template {
      metadata {
        labels = local.webserver_labels
      }

      spec {
        dynamic "volume" {
          for_each = local.webserver_pvs
          content {
            name = volume.key

            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.pvc[volume.key].metadata[0].name
            }
          }
        }

        container {
          name  = "webserver"
          image = "ghcr.io/paperless-ngx/paperless-ngx:latest"

          port {
            host_port      = 8000
            container_port = 8000
            protocol       = "TCP"
          }

          env {
            name  = "PAPERLESS_URL"
            value = var.paperless_url
          }

          env {
            name  = "PAPERLESS_AUTO_LOGIN_USERNAME"
            value = "daniel"
          }

          env {
            name  = "PAPERLESS_REDIS"
            value = "redis://$(BROKER_SERVICE_HOST):$(BROKER_SERVICE_PORT)"
          }

          env {
            name  = "PAPERLESS_TIKA_ENABLED"
            value = "1"
          }

          env {
            name  = "PAPERLESS_TIKA_ENDPOINT"
            value = "http://$(TIKA_SERVICE_HOST):$(TIKA_SERVICE_PORT)"
          }

          env {
            name  = "PAPERLESS_TIKA_GOTENBERG_ENDPOINT"
            value = "http://$(GOTENBERG_SERVICE_HOST):$(GOTENBERG_SERVICE_PORT)"
          }

          env {
            name  = "PAPERLESS_AUTO_LOGIN_USERNAME"
            value = "daniel"
          }

          dynamic "volume_mount" {
            for_each = local.webserver_pvs
            content {
              name       = volume_mount.key
              mount_path = volume_mount.value.mount_path
            }
          }

          liveness_probe {
            exec {
              command = ["curl", "-fs", "-S", "--max-time", "2", "http://localhost:8000"]
            }

            timeout_seconds   = 10
            period_seconds    = 30
            failure_threshold = 5
          }
        }

        restart_policy = "Always"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

