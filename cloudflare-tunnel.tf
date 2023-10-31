data "cloudflare_accounts" "d-jensen_de" {
  name = "daniel+cloudflare@d-jensen.de"
}

resource "random_password" "tunnel_secret" {
  length = 32
}

resource "cloudflare_tunnel" "olymp" {
  account_id = data.cloudflare_accounts.d-jensen_de.id
  name       = "olymp"
  secret     = base64encode(random_password.tunnel_secret.result)
}
