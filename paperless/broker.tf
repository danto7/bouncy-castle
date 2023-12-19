locals {
  broker_labels = {
    name = "broker"
  }
  broker_pvs = { for key, value in local.pvs : key => value if value.deployment == "broker" }
}

resource "kubernetes_service" "broker" {
  metadata {
    name      = local.broker_labels.name
    namespace = var.namespace
  }

  spec {
    port {
      port        = 6379
      target_port = "6379"
    }

    selector = local.broker_labels
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
        dynamic "volume" {
          for_each = local.broker_pvs
          content {
            name = volume.key

            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.pvc[volume.key].metadata[0].name
            }
          }
        }

        container {
          name  = local.broker_labels.name
          image = "docker.io/library/redis:7"

          dynamic "volume_mount" {
            for_each = local.broker_pvs
            content {
              name       = volume_mount.key
              mount_path = volume_mount.value.mount_path
            }
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

