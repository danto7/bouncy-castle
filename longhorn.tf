resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}
resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.5.1"
  namespace  = kubernetes_namespace.longhorn.metadata[0].name

  values = [yamlencode({
    csi = {
      attacherReplicaCount    = 1
      provisionerReplicaCount = 1
      resizerReplicaCount     = 1
      snapshotterReplicaCount = 1
    }
    longhornUI = {
      replicas = 1
    }
    persistence = {
      defaultDataLocality      = "best-effort"
      defaultClassReplicaCount = 2
      reclaimPolicy            = "Retain"
    }
    defaultSettings = {
      backupTarget                                = "nfs://192.168.188.7:/mnt/ravenclaw/olymp-backup"
      allowVolumeCreationWithDegradedAvailability = false
      replicaSoftAntiAffinity                     = false
    }
    longhornManager = {
      serviceAnnotations = {
        "prometheus.io/scrape" = "true"
        "prometheus.io/path"   = "/metrics"
        "prometheus.io/port"   = "9500"
      }
    }
  })]
}

