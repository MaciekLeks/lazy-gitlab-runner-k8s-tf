terraform {
  required_providers {
    toml = {
      source  = "Tobotimus/toml"
      version = ">= 0.3.0"
    }
  }

  required_version = ">= 1.8.0"
}

provider "toml" {
}

