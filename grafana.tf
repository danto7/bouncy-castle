locals {
  grafana_image = "grafana/grafana@sha256:40aaa21a9f7602816b754eb293139c3173629b83829faf1f510e19f76e486e41"
}

resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "kubernetes_persistent_volume_claim" "grafana" {
  metadata {
    name      = "grafana-data"
    namespace = kubernetes_namespace.grafana.metadata[0].name
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

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.grafana.metadata[0].name

    labels = {
      app = "grafana"
    }
  }

  spec {
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.grafana.metadata[0].name
          }
        }

        container {
          name  = "grafana"
          image = local.grafana_image

          port {
            name           = "http-grafana"
            container_port = 3000
            protocol       = "TCP"
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ENABLED"
            value = "true"
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ORG_NAME"
            value = "Main Org."
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ORG_ROLE"
            value = "Admin"
          }

          env {
            name  = "GF_AUTH_DISABLE_LOGIN_FORM"
            value = "true"
          }

          env {
            name  = "GF_AUTH_DISABLE_SIGNOUT_MENU"
            value = "true"
          }

          env {
            name  = "GF_SECURITY_DISABLE_INITIAL_ADMIN_CREATION"
            value = "true"
          }

          env {
            name  = "GF_SERVER_ROOT_URL"
            value = "https://grafana.d-jensen.de"
          }

          env {
            name  = "GF_DATABASE_WAL"
            value = "true"
          }

          resources {
            requests = {
              cpu = "250m"

              memory = "750Mi"
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/grafana"
          }

          liveness_probe {
            tcp_socket {
              port = "3000"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/robots.txt"
              port   = "3000"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 2
            period_seconds        = 30
            success_threshold     = 1
            failure_threshold     = 3
          }

          image_pull_policy = "IfNotPresent"
        }

        security_context {
          supplemental_groups = [0]
          fs_group            = 472
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 3000
      target_port = "http-grafana"
    }

    selector = {
      app = "grafana"
    }
  }
}

