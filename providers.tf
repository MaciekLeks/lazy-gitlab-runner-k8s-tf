terraform {
  required_providers {
    toml = {
      source  = "Tobotimus/toml"
      version = ">= 0.3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
  }

  required_version = ">= 1.8.0"
}

provider "toml" {
}

//TODO - remove this block
//test block
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


//


