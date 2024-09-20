variable "helm_settings" {
  description = "The settings for the Helm chart."
  type = object({
    name             = optional(string, "gitlab-runner")
    repository       = optional(string, "https://charts.gitlab.io")
    chart            = optional(string, "gitlab-runner")
    namespace        = optional(string, "gitlab-runner")
    version          = optional(string, null) //default to last version
    create_namespace = optional(bool, false)
    atomic           = optional(bool, true)
    wait             = optional(bool, true)
    timeout          = optional(number, 300)
  })
  default = {}
}


variable "image" {
  description = "The docker gitlab runner image."
  default     = {}
  type = object({
    registry : optional(string, "registry.gitlab.com")
    image : optional(string, "gitlab-org/gitlab-runner")
    tag : optional(string)
  })
}

variable "useTiny" {
  description = "Use the tiny runner image"
  default     = false
  type        = bool
}

variable "imagePullPolicy" {
  description = "Specify the job images pull policy: Never, IfNotPresent, Always."
  type        = string
  default     = "IfNotPresent"
  validation {
    condition     = contains(["Never", "IfNotPresent", "Always"], var.imagePullPolicy)
    error_message = "Must be one of: \"Never\", \"IfNotPresent\", \"Always\"."
  }
}

variable "imagePullSecrets" {
  description = "A array of secrets that are used to authenticate Docker image pulling."
  type        = list(object({ name = string }))
  default     = null
}

variable "livenessProbe" {
  type = object({
    initial_delay_seconds            = optional(number, 60)
    period_seconds                   = optional(number, 10)
    success_threshold                = optional(number, 1)
    failure_threshold                = optional(number, 3)
    termination_grace_period_seconds = optional(number, 30)
  })
  default = {}
}

variable "readinessProbe" {
  type = object({
    initial_delay_seconds = optional(number, 60)
    period_seconds        = optional(number, 10)
    success_threshold     = optional(number, 1)
    failure_threshold     = optional(number, 3)
  })
  default = {}
}

variable "replicas" {
  description = "The number of runner pods to create."
  type        = number
  default     = 1
}

variable "runnerToken" {
  description = "The Runner Token for adding new Runners to the GitLab Server."
  type        = string
}

variable "unregisterRunners" {
  description = "Unregister runners before termination."
  type        = bool
  default     = true
}


variable "terminationGracePeriodSeconds" {
  description = "When stopping the runner, give it time (in seconds) to wait for its jobs to terminate."
  type        = number
  default     = 3600
}

variable "certSecretName" {
  description = "Set the certsSecretName in order to pass custom certficates for GitLab Runner to use."
  type        = string
  default     = null
}

variable "concurrent" {
  default     = 10
  description = "Configure the maximum number of concurrent jobs"
  type        = number
}


variable "shutdown_timeout" {
  description = "Number of seconds until the forceful shutdown operation times out and exits the process. The default value is 30. If set to 0 or lower, the default value is used."
  type        = number
  default     = 0
}


variable "checkInterval" {
  description = "Defines in seconds how often to check GitLab for a new builds."
  type        = number
  default     = 3
}

variable "logLevel" {
  description = "Configure GitLab Runner's logging level. Available values are: debug, info, warn, error, fatal, panic."
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "warn", "error", "fatal", "panic"], var.log_level)
    error_message = "Must be one of: \"debug\", \"info\", \"warn\", \"error\", \"fatal\", \"panic\"."
  }
}


variable "runners" {
  type = list(object({

    name     = string
    executor = optional(string, "kubernetes")
    shell    = optional(string, "bash")
    url      = optional(string, "https://gitlab.com/") //TODO: values.gitlabUrl? The GitLab Server URL (with protocol) that want to register the runner against

    environment = optional(list(string), null)

    kubernetes = object({
      namespace       = string
      pod_labels      = optional(map(string), null) // job's pods labels
      pod_annotations = optional(map(string), null) // job's annotations

      image                            = optional(string) //The image to run jobs with.
      helper_image                     = optional(string) //The default helper image used to clone repositories and upload artifacts.
      helper_image_flavor              = optional(string) //Sets the helper image flavor (alpine, alpine3.16, alpine3.17, alpine3.18, alpine3.19, alpine-latest, ubi-fips or ubuntu). Defaults to alpine. The alpine flavor uses the same version as alpine3.19.
      helper_image_autoset_arch_and_os = optional(string) //Uses the underlying OS to set the Helper Image ARCH and OS.



      // cpu requests and limits
      cpu_limit : optional(string)
      cpu_limit_overwrite_max_allowed : optional(string)
      cpu_request : optional(string)
      cpu_request_overwrite_max_allowed : optional(string)
      memory_limit : optional(string)
      memory_limit_overwrite_max_allowed : optional(string)
      memory_request : optional(string)
      memory_request_overwrite_max_allowed : optional(string)
      ephemeral_storage_limit : optional(string)
      ephemeral_storage_limit_overwrite_max_allowed : optional(string)
      ephemeral_storage_request : optional(string)
      ephemeral_storage_request_overwrite_max_allowed : optional(string)

      //helper containers
      helper_cpu_limit : optional(string)
      helper_cpu_limit_overwrite_max_allowed : optional(string)
      helper_cpu_request : optional(string)
      helper_cpu_request_overwrite_max_allowed : optional(string)
      helper_memory_limit : optional(string)
      helper_memory_limit_overwrite_max_allowed : optional(string)
      helper_memory_request : optional(string)
      helper_memory_request_overwrite_max_allowed : optional(string)
      helper_ephemeral_storage_limit : optional(string)
      helper_ephemeral_storage_limit_overwrite_max_allowed : optional(string)
      helper_ephemeral_storage_request : optional(string)
      helper_ephemeral_storage_request_overwrite_max_allowed : optional(string)

      // service containers
      service_cpu_limit : optional(string)
      service_cpu_limit_overwrite_max_allowed : optional(string)
      service_cpu_request : optional(string)
      service_cpu_request_overwrite_max_allowed : optional(string)
      service_memory_limit : optional(string)
      service_memory_limit_overwrite_max_allowed : optional(string)
      service_memory_request : optional(string)
      service_memory_request_overwrite_max_allowed : optional(string)
      service_ephemeral_storage_limit : optional(string)
      service_ephemeral_storage_limit_overwrite_max_allowed : optional(string)
      service_ephemeral_storage_request : optional(string)
      service_ephemeral_storage_request_overwrite_max_allowed : optional(string)

      volumes = optional(object({
        empty_dir = optional(list(object({
          name       = string
          mount_path = string
          medium     = optional(string, null)
          size_limit = optional(string, null)
        })), null)
      }), null)
    })

    // start of cache block
    cache = optional(object({
      Type                   = optional(string, "local")
      Path                   = optional(string, "")
      Shared                 = optional(bool)
      MaxUploadedArchiveSize = optional(number)
      gcs = optional(object({
        CredentialsFile : optional(string)
        AccessId : optional(string)
        PrivateKey : optional(string)
        BucketName : string
      }), null)
      s3          = optional(map(any), null) //TODO: add static typing as for gcs
      azure       = optional(map(any), null) //TODO: add static typing as for gcs
      secret_name = optional(string)
    }), null)
    // end of cache block

    affinity = optional(object({
      node_affinity : optional(object({
        preferred_during_scheduling_ignored_during_execution : optional(list(object({
          weight : number
          preference : object({
            match_expressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            match_fields : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
          })
        })), null)
        required_during_scheduling_ignored_during_execution : optional(list(object({
          node_selector_terms : object({
            match_expressions : optional(object({
              key : string
              operator : string
              values : list(string)
            }))
            match_fields : optional(object({
              key : string
              operator : string
              values : list(string)
            }))
          })
        })), null)
      }), null)

      pod_affinity : optional(object({
        preferred_during_scheduling_ignored_during_execution : optional(list(object({
          pod_affinity_term : object({
            weight : number
            topology_key : string
            namespaces : optional(list(string))
            label_selector : optional(object({
              match_expressions : optional(list(object({
                key : string
                operator : string
                values : list(string)
              })))
              match_labels : optional(list(string))
            }))
            namespace_selector : optional(object({
              match_expressions : optional(list(object({
                key : string
                operator : string
                values : list(string)
              })))
              match_labels : optional(list(string))
            }))
          })
        })), null)
        required_during_scheduling_ignored_during_execution : optional(list(object({
          topology_key : string
          namespaces : optional(list(string))
          label_selector : optional(object({
            match_expressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            match_labels : optional(list(string))
          }))
          namespace_selector : optional(object({
            match_expressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            match_labels : optional(list(string))
          }))
        })), null)
      }), null)

      pod_anti_affinity : optional(object({
        preferred_during_scheduling_ignored_during_execution : optional(list(object({
          pod_affinity_term : object({
            weight : number
            topology_key : string
            namespaces : optional(list(string))
            label_selector : optional(object({
              match_expressions : optional(list(object({
                key : string
                operator : string
                values : list(string)
              })))
              match_labels : optional(list(string))
            }))
            namespace_selector : optional(object({
              match_expressions : optional(list(object({
                key : string
                operator : string
                values : list(string)
              })))
              match_labels : optional(list(string))
            }))
          })
        })), null)
        required_during_scheduling_ignored_during_execution : optional(list(object({
          topology_key : string
          namespaces : optional(list(string))
          label_selector : optional(object({
            match_expressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            match_labels : optional(list(string))
          }))
          namespace_selector : optional(object({
            match_expressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            match_labels : optional(list(string))
          }))
        })), null)
      }), null)
    }), null) //affinity

  })) //runners 

  //start executor validation block
  validation {
    condition = alltrue([
      for r in var.runners : contains(["kubernetes"], r.executor)
    ])
    error_message = "Must be: \"kubernetes\"."
  }
  // end of executor validation block

  // start of cache validation block
  validation {
    condition = alltrue([
      for r in var.runners : r.cache != null ? r.cache.Type == "gcs" ? r.cache.gcs.BucketName != null : true : true
    ])
    error_message = "To use the gcs cache type you must configure at least gcs.BucketName"
  }
  validation {
    condition = alltrue([
      for r in var.runners : r.cache != null ? r.cache.Type == "azure" ? length(r.cache.azure) > 0 : true : true
    ])
    //TODO: after adding static typing change it accordingly
    error_message = "To use the azure cache type you must set var.cache.azure. see https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscache-section for config details."
  }
  validation {
    condition = alltrue([
      for r in var.runners : r.cache != null ? r.cache.Type == "s3" ? length(r.cache.azure) > 0 : true : true
    ])
    //TODO: after adding static typing change it accordingly
    error_message = "To use the s3 cache type you must set var.cache.s3 see https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscache-section for config details."
  }
  validation {
    condition = alltrue([
      for r in var.runners : r.cache != null ? contains(["s3", "gcs", "azure", "local"], r.cache.Type) : true
    ])
    error_message = "Cache type must be one of 's3', 'gcs', 'azure', or 'local'."
  }
  // end of cache validation block

  validation {
    condition     = length(var.runners) > 0
    error_message = "At least one runner must be defined"
  }
  validation {
    condition = alltrue([
      for r in var.runners : contains(["kubernetes"], r.executor)
    ])
    error_message = "Must be one of: \"bash\", \"sh\", \"powershell\", \"pwsh\"."

  }
  validation {
    condition = alltrue([
      for r in var.runners : contains(["bash", "sh", "powershell", "pwsh"], r.shell)
    ])
    error_message = "Must be one of: \"bash\", \"sh\", \"powershell\", \"pwsh\"."
  }
}

