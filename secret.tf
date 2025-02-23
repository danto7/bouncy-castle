data "bitwarden-secrets-manager_project" "this" {
  id = "29b0d99c-0698-426f-99d4-b0dd00a66d1b"
}
output "project" {
  value = data.bitwarden-secrets-manager_project.this
}

data "bitwarden-secrets-manager_secret" "this" {
  id = "d89fe0b7-fb3b-4b85-af1a-b2330091f86e"
}
output "secret" {
  value = data.bitwarden-secrets-manager_secret.this
}
