terraform {
  cloud {
    organization = "d-jensen"

    workspaces {
      name = "olymp"
    }
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "random" {
}

provider "kubernetes" {
  ignore_labels = [
    "recurring-job-group.longhorn.io/default"
  ]
}

provider "helm" {
  kubernetes {
  }
}

provider "cloudflare" {
}
