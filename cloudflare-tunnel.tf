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
