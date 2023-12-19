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
    access_modes       = each.value.access_modes
    storage_class_name = "longhorn"

    resources {
      requests = {
        storage = each.value.storage
      }
    }

    volume_name = kubernetes_persistent_volume.pv[each.key].metadata.0.name
  }

  depends_on = [kubernetes_persistent_volume.pv]
}

resource "kubernetes_persistent_volume" "pv" {
  for_each = local.pvs

  metadata {
    name = "${var.namespace}-${each.key}"
  }

  spec {
    access_modes       = each.value.access_modes
    storage_class_name = "longhorn"

    capacity = {
      storage = each.value.storage
    }

    persistent_volume_source {
      csi {
        driver        = "driver.longhorn.io"
        fs_type       = "ext4"
        volume_handle = "${var.namespace}-${each.key}"
        volume_attributes = {
          dataLocality        = "best-effort"
          fsType              = "ext4"
          numberOfReplicas    = 2
          staleReplicaTimeout = 30
        }
      }
    }
  }
}
