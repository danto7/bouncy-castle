locals {
  grafana_tag = "10.2.0"
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
    access_modes = ["ReadWriteMany"]

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
          image = "grafana/grafana:${local.grafana_tag}"

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
