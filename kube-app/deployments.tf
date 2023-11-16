
locals {
  volumes = { for name, volume in var.volumes :
    name => {
      pvc_name       = "${var.name}-${name}"
      container_path = volume.container_path
      size           = volume.size
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        name = var.name
      }
    }

    template {
      metadata {
        labels = {
          name = var.name
        }
      }

      spec {
        dynamic "volume" {
          for_each = local.volumes

          content {
            name = volume.key

            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.app[volume.key].metadata[0].name
            }
          }

        }

        container {
          name  = var.name
          image = var.image

          dynamic "port" {
            for_each = var.ports
            content {
              name           = port.key
              host_port      = port.value.port
              container_port = port.value.port
              protocol       = port.value.protocol
            }
          }

          dynamic "env" {
            for_each = var.envs
            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "volume_mount" {
            for_each = local.volumes
            content {
              name       = volume_mount.key
              mount_path = volume_mount.value.container_path
            }
          }

          // liveness_probe {
          //   exec {
          //     command = ["curl", "-fs", "-S", "--max-time", "2", "http://localhost:8000"]
          //   }

          //   timeout_seconds   = 10
          //   period_seconds    = 30
          //   failure_threshold = 5
          // }
        }

        restart_policy = "Always"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "app" {
  for_each = local.volumes

  metadata {
    name      = each.value.pvc_name
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = each.value.size
      }
    }
  }
}

resource "kubernetes_service" "app" {
  count = length(var.ports) > 0 ? 1 : 0

  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    dynamic "port" {
      for_each = var.ports
      content {
        name        = port.key
        port        = port.value.port
        protocol    = port.value.protocol
        target_port = port.key
      }
    }

    selector = {
      name = var.name
    }
  }
}

