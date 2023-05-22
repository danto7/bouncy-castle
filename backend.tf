terraform {
  cloud {
    workspaces {
      tags = ["prod"]
    }
  }
}

