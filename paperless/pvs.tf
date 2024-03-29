locals {
  pvs = {
    data = {
      deployment   = "webserver"
      storage      = "10Gi",
      access_modes = ["ReadWriteOnce"]
      mount_path   = "/usr/src/paperless/data"
    }
    media = {
      deployment   = "webserver"
      storage      = "10Gi",
      access_modes = ["ReadWriteOnce"]
      mount_path   = "/usr/src/paperless/media"
    }
    export = {
      deployment   = "webserver"
      storage      = "100Mi",
      access_modes = ["ReadWriteOnce"]
      mount_path   = "/usr/src/paperless/export"
    }
    consume = {
      deployment   = "webserver"
      storage      = "100Mi",
      access_modes = ["ReadWriteOnce"]
      mount_path   = "/usr/src/paperless/consume"
    }
    redisdata = {
      deployment   = "broker"
      storage      = "100Mi",
      access_modes = ["ReadWriteOnce"]
      mount_path   = "/data"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  for_each = local.pvs

  metadata {
    name      = each.key
    namespace = var.namespace
  }

  spec {
    access_modes = each.value.access_modes

    resources {
      requests = {
        storage = each.value.storage
      }
    }

    volume_name = "${var.namespace}-${each.key}"
  }
}

# resource "kubernetes_persistent_volume" "pv" {
#   for_each = local.pvs
# 
#   metadata {
#     name = "${var.namespace}-${each.key}"
#   }
# 
#   spec {
#     access_modes       = each.value.access_modes
#     storage_class_name = "longhorn"
# 
#     claim_ref {
#       name      = each.key
#       namespace = var.namespace
#     }
# 
#     capacity = {
#       storage = each.value.storage
#     }
# 
#     persistent_volume_source {
#     }
#   }
# }
