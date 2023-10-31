locals {
  broker_labels = {
    name = "broker"
  }
}

resource "kubernetes_deployment" "broker" {
  metadata {
    name      = local.broker_labels.name
    namespace = var.namespace
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
    namespace = var.namespace
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

