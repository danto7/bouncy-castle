terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

provider "kubernetes" {
  //cluster_ca_certificate = var.kubernetes_cluster_cert
}

provider "helm" {
  kubernetes {
    //cluster_ca_certificate = var.kubernetes_cluster_cert
  }
}
