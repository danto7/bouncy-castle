resource "kubernetes_namespace" "paperless" {
  metadata {
    name = "paperless"
  }
}

locals {
  broker_labels = {
    name = "broker"
  }
}

resource "kubernetes_deployment" "broker" {
  metadata {
    labels    = local.broker_labels
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.broker_labels
    }

    template {
      metadata {
        labels = local.broker_labels
      }

      spec {
        volume {
          name = "redisdata"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.redisdata.metadata[0].name
          }
        }

        container {
          name  = local.broker_labels.name
          image = "docker.io/library/redis:7"

          volume_mount {
            name       = "redisdata"
            mount_path = "/data"
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

resource "kubernetes_persistent_volume_claim" "redisdata" {
  metadata {
    name      = "redisdata"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "100Mi"
      }
    }
  }
}

/*
locals {
  gotenberg_labels = {
    name = "gotenberg"
  }
}
resource "kubernetes_deployment" "gotenberg" {
  metadata {
    labels    = local.gotenberg_labels
    namespace = kubernetes_namespace.paperless.metadata[0].name
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

locals {
  tika_labels = {
    name = "tika"
  }
}
resource "kubernetes_deployment" "tika" {
  metadata {
    labels    = local.tika_labels
    namespace = kubernetes_namespace.paperless.metadata[0].name
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

locals {
  webserver_labels = {
    name = "webserver"
  }
}

resource "kubernetes_service" "webserver" {
  metadata {
    labels    = local.webserver_labels
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    port {
      name        = "http"
      port        = 8000
      target_port = "8000"
    }

    selector = local.webserver_labels
  }
}

resource "kubernetes_deployment" "webserver" {
  metadata {
    labels    = local.webserver_labels
    namespace = kubernetes_namespace.paperless.metadata[0].name
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
        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.data.metadata[0].name
          }
        }

        volume {
          name = "media"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.media.metadata[0].name
          }
        }

        volume {
          name = "export"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.export.metadata[0].name
          }
        }

        volume {
          name = "consume"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.consume.metadata[0].name
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
            name  = "PAPERLESS_REDIS"
            value = "redis://broker:6379"
          }

          env {
            name  = "PAPERLESS_TIKA_ENABLED"
            value = "1"
          }

          env {
            name  = "PAPERLESS_TIKA_ENDPOINT"
            value = "http://tika:9998"
          }

          env {
            name  = "PAPERLESS_TIKA_GOTENBERG_ENDPOINT"
            value = "http://gotenberg:3000"
          }

          volume_mount {
            name       = "data"
            mount_path = "/usr/src/paperless/data"
          }

          volume_mount {
            name       = "media"
            mount_path = "/usr/src/paperless/media"
          }

          volume_mount {
            name       = "export"
            mount_path = "/usr/src/paperless/export"
          }

          volume_mount {
            name       = "consume"
            mount_path = "/usr/src/paperless/consume"
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

resource "kubernetes_persistent_volume_claim" "data" {
  metadata {
    name      = "data"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "media" {
  metadata {
    name      = "media"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "export" {
  metadata {
    name      = "export"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "100Mi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "consume" {
  metadata {
    name      = "consume"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "100Mi"
      }
    }
  }
}
*/
