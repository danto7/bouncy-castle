resource "auth0_resource_server" "kubernetes" {
  name        = "Kubernetes"
  identifier  = "kubernetes"
  signing_alg = "RS256"

  allow_offline_access                            = true
  token_lifetime                                  = 86400
  skip_consent_for_verifiable_first_party_clients = true
  token_dialect                                   = "access_token_authz"

  scopes {
    value       = "cluster-admin"
    description = "Kubernetes Cluster Administrator"
  }
}

resource "auth0_action" "attach_roles" {
  name    = "attach roles"
  runtime = "node16"
  deploy  = true
  code    = file("./auth0_attach_roles_action.js")

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}
