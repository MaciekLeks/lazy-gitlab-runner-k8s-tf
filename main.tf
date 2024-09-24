locals {
  runners_config = provider::toml::encode({
    runners = var.runners
  })

  values = {
    image            = var.image
    useTiny          = var.useTiny
    imagePullPolicy  = var.imagePullPolicy
    imagePullSecrets = var.imagePullSecrets

    livenessProbe  = var.livenessProbe
    readinessProbe = var.readinessProbe

    replicas = var.replicas

    runnerToken                   = var.runnerToken
    uregisterRunners              = var.unregisterRunners
    terminationGracePeriodSeconds = var.terminationGracePeriodSeconds
    concurrent                    = var.concurrent
    certSecretName                = var.certSecretName
    shutdown_timeout              = var.shutdown_timeout
    checkInterval                 = var.checkInterval
    logLevel                      = var.logLevel
    logFormat                     = var.logFormat
    sentryDsn                     = var.sentryDsn
    connectionMaxAge              = var.connectionMaxAge
    preEntryScript                = var.preEntryScript
    sessionServer                 = var.sessionServer
    rbac                          = var.rbac
    serviceAccount                = var.serviceAccount
    metrics                       = var.metrics
    service                       = var.service



    runners = {
      config = local.runners_config
    }
  }
}

//TODO: uncomment this block to create the helm_release resource
resource "helm_release" "gitlab_runner" {
  name             = var.helm_settings.name
  repository       = var.helm_settings.repository
  chart            = var.helm_settings.chart
  namespace        = var.helm_settings.namespace
  version          = var.helm_settings.version
  create_namespace = var.helm_settings.create_namespace
  atomic           = var.helm_settings.atomic
  wait             = var.helm_settings.wait
  timeout          = var.helm_settings.timeout

  values = [yamlencode(local.values)]
}

output "helm_release" {
  value     = helm_release.gitlab_runner
  sensitive = true
}


output "helm_values" {
  value = local.values
}

output "runners_config" {
  value = local.runners_config
}

//----------------------------------------------------------------
//locals {
#   hcl = {
#     "name" = "Tobotimus"
#     "age"  = 100
#     mapa = {
#       "key1" = {
#         "key1.1" = "value1.1"
#         "key1.2" = "value1.2"
#       }
#       "key2" = {
#         "key2.1" = "value2.1"
#         "key2.2" = "value2.2"
#       }
#
#     }
#     tablica = [
#       "element1",
#       "element2"
#     ]
#
#   }
#
#   toml = provider::toml::encode(local.hcl)
#
#
# }
#
# output "toml" {
#   value = local.toml
# }

