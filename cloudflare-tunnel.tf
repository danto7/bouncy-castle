data "cloudflare_accounts" "d-jensen_de" {
  name = "Daniel+cloudflare@d-jensen.de's Account"
}

resource "random_password" "tunnel_secret" {
  length = 32
}

resource "cloudflare_tunnel" "olymp" {
  account_id = data.cloudflare_accounts.d-jensen_de.accounts[0].id
  name       = "olymp"
  secret     = base64encode(random_password.tunnel_secret.result)
}

resource "kubernetes_namespace" "tunnel" {
  metadata {
    name = "cloudflare-tunnel"
  }
}

resource "kubernetes_secret" "tunnel" {
  metadata {
    name      = "cloudflare-tunnel"
    namespace = kubernetes_namespace.tunnel.metadata[0].name
  }

  data = {
    TUNNEL_TOKEN = cloudflare_tunnel.olymp.tunnel_token
  }
}

resource "kubernetes_config_map" "tunnel" {
  metadata {
    name      = "tunnel"
    namespace = kubernetes_namespace.tunnel.metadata[0].name
  }

  data = {
    tunnel = cloudflare_tunnel.olymp.id
    ingress = [
      {
        hostname = "paperless.d-jensen.de"
        service  = module.paperless.endpoint
      }
    ]
  }
}

resource "kubernetes_deployment" "tunnel" {
  metadata {
    name      = "cloudflare-tunnel"
    namespace = kubernetes_namespace.tunnel.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        name = "cloudflare-tunnel"
      }
    }

    template {
      metadata {
        labels = {
          name = "cloudflare-tunnel"
        }
      }

      spec {
        container {
          name  = "tunnel"
          image = "cloudflare/cloudflared:latest"
          args  = ["tunnel", "--no-autoupdate", "run"]

          env_from {
            secret_ref {
              name = kubernetes_secret.tunnel.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.tunnel.metadata[0].name
            }
          }
        }

        restart_policy = "Always"
      }
    }
  }
}


