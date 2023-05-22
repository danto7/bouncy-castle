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
