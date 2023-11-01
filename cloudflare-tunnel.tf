data "cloudflare_accounts" "d-jensen_de" {
  name = "Daniel+cloudflare@d-jensen.de's Account"
}

data "cloudflare_zone" "d-jensen_de" {
  name = "d-jensen.de"
}

resource "cloudflare_record" "paperless" {
  zone_id = data.cloudflare_zone.d-jensen_de.zone_id
  name    = "paperless"
  value   = cloudflare_tunnel.olymp.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_tunnel_config" "example_config" {
  account_id = data.cloudflare_accounts.d-jensen_de.accounts[0].id
  tunnel_id  = cloudflare_tunnel.olymp.id

  config {
    ingress_rule {
      hostname = "paperless.d-jensen.de"
      service  = module.paperless.endpoint
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "random_password" "tunnel_secret" {
  length = 32
}

resource "cloudflare_tunnel" "olymp" {
  account_id = data.cloudflare_accounts.d-jensen_de.accounts[0].id
  name       = "olymp"
  secret     = base64encode(random_password.tunnel_secret.result)
  config_src = "cloudflare"
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
        annotations = {
          "prometheus.io/scrape" = true
          "prometheus.io/port"   = 9000
          "prometheus.io/path"   = "/metrics"
        }
      }

      spec {
        container {
          name  = "tunnel"
          image = "cloudflare/cloudflared:latest"
          args = [
            "tunnel",
            "--no-autoupdate",
            "--metrics",
            ":9000",
            "run",
          ]

          port {
            container_port = 9000
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.tunnel.metadata[0].name
            }
          }
        }
      }
    }
  }
}


