terraform {
  backend "remote" {
    organization = "ash-enterprise"

    workspaces {
      name = "ash-dev"
    }
  }
}