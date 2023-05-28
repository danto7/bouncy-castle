terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "0.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

provider "auth0" {}

provider "kubernetes" {}

provider "helm" {
  kubernetes {
    insecure = true
  }
}
