
locals {
  hcl = {
    "name" = "Tobotimus"
    "age"  = 100
    mapa = {
      "key1" = {
        "key1.1" = "value1.1"
        "key1.2" = "value1.2"
      }
      "key2" = {
        "key2.1" = "value2.1"
        "key2.2" = "value2.2"
      }

    }
    tablica = [
      "element1",
      "element2"
    ]

  }

  toml = provider::toml::encode(local.hcl)


}

output "toml" {
  value = local.toml
}



locals {
  runners_config = provider::toml::encode({
    runners = var.runners
  })

  values = {
    image            = var.image
    useTiny          = var.useTiny
    imagePullPolicy  = var.imagePullPolicy
    imagePullSecrets = var.imagePullSecrets
    concurrent       = var.concurrent

    runners = provider::toml::encode({
      config = local.runners_config
    })

  }
}

output "helm_values" {
  value = local.values
}

output "runners_config" {
  value = local.runners_config
}


