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

variable "kubernetes_cluster_cert" {
  type        = string
  description = "cluster cert in pem format"
}

provider "auth0" {}

provider "kubernetes" {
  //cluster_ca_certificate = var.kubernetes_cluster_cert
}

provider "helm" {
  kubernetes {
    //cluster_ca_certificate = var.kubernetes_cluster_cert
  }
}
