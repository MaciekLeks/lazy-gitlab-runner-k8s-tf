locals {
  runners_config = provider::toml::encode({
    runners = var.runners
  })

  values_file = var.values_file != null ? file(var.values_file) : ""

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
    scheulerName                  = var.schedulerName

    runners = {
      config     = local.runners_config
      configPath = var.configPath
    }

    securityContext              = var.securityContext
    strategy                     = var.strategy
    podSecurityContext           = var.podSecurityContext
    resources                    = var.resources
    affinity                     = var.affinity
    topologySpreadConstraints    = var.topologySpreadConstraints
    nodeSelector                 = var.nodeSelector
    tolerations                  = var.tolerations
    envVars                      = var.envVars
    extraEnv                     = var.extraEnv
    extraEnvVars                 = var.extraEnvFrom
    hostAliases                  = var.hostAliases
    deploymentAnnotations        = var.deploymentAnnotations
    deploymentLabels             = var.deploymentLabels
    deploymentLifecycle          = var.deploymentLifecycle
    hpa                          = var.hpa
    priorityClassName            = var.priorityClassName
    secrets                      = var.secrets
    automountServiceAccountToken = var.automountServiceAccountToken
    configMaps                   = var.configMaps
    volumeMounts                 = var.volumeMounts
    volumes                      = var.volumes
    extraObjects                 = var.extraObjects

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

  values = [
    yamlencode(local.values),
    yamlencode(var.values),
    local.values_file
  ]
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

