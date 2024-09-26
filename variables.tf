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

variable "values_file" {
  description = "Path to Values file to be passed to gitlab-runner helm chart"
  default     = null
  type        = string
}

variable "values" {
  description = "Additional values to be passed to the gitlab-runner helm chart"
  default     = {}
  type        = map(any)
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
  type = list(object({
    name = string
  }))
  default = null
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
    condition     = contains(["debug", "info", "warn", "error", "fatal", "panic"], var.logLevel)
    error_message = "Must be one of: \"debug\", \"info\", \"warn\", \"error\", \"fatal\", \"panic\"."
  }
}

variable "logFormat" {
  description = "Specifies the log format. Options are runner, text, and json. This setting has lower priority than the format set by command-line argument --log-format. The default value is runner, which contains ANSI escape codes for coloring."
  type        = string
  default     = "runner"
  validation {
    condition     = contains(["runner", "text", "json"], var.logFormat)
    error_message = "Must be one of: \"runner\", \"text\", \"json\"."
  }
}

variable "sentryDsn" {
  description = "Configure GitLab Runner's Sentry DSN."
  type        = string //TODO: ?
  default     = null
}

variable "connectionMaxAge" {
  description = "Configure GitLab Runner's maximum connection age for TLS keepalive connections."
  type        = string
  default     = "15m0s"
}

variable "preEntryScript" {
  description = "A custom bash script that will be executed prior to the invocation of the gitlab-runner process"
  type        = string
  default     = null
}

variable "sessionServer" {
  description = "Configuration for the session server"
  type = object({
    enabled                  = optional(bool, false)
    annotations              = optional(map(string), null)
    timeout                  = optional(number, null)
    internalPort             = optional(number, null)
    externalPort             = optional(number, null)
    nodePort                 = optional(number, null)
    publicIP                 = optional(string, null)
    loadBalancerSourceRanges = optional(list(string), null)
    serviceType              = optional(string, null)
  })
  default = {}
  validation {
    condition     = var.sessionServer.enabled ? contains(["ClusterIP", "Headless", "NodePort", "LoadBalancer"], var.sessionServer.serviceType) : true
    error_message = "The serviceType must be one of: ClusterIP, Headless, NodePort, LoadBalancer."
  }
}

variable "rbac" {
  description = "RBAC support."
  type = object({
    create : optional(bool, false) #create k8s SA and apply RBAC roles #depreciated

    rules : optional(list(object({           # Define list of rules to be added to the rbac role permissions.
      resources : optional(list(string), []) #resources : optional(list(string), ["pods", "pods/exec", "pods/attach", "secrets", "configmaps"])
      apiGroups : optional(list(string), [""])
      verbs : optional(list(string)) #verbs : optional(list(string), ["get", "list", "watch", "create", "patch", "delete"])
    })), [])

    clusterWideAccess : optional(bool, false)

    podSecurityPolicy : optional(object({
      enabled : optional(bool, false)
      resourceNames : optional(list(string), [])
    }), {})
  })
  default = {}
}


variable "serviceAccount" {
  description = "The name of the k8s service account to create (since 17.x.x)"
  type = object({
    create           = optional(bool, false)
    name             = optional(string, "")
    annotations      = optional(map(string), {})
    imagePullSecrets = optional(list(string), [])
  })
  default = {}
}

variable "metrics" {
  description = "Configure integrated Prometheus metrics exporter."
  type = object({
    enabled : optional(bool, false)
    portName : optional(string, "metrics")
    port : optional(number, 9252)
    serviceMonitor : optional(object({
      enabled : optional(bool, false)
      labels : optional(map(string), {})
      annotations : optional(map(string), {})
      interval : optional(string, "1m")
      scheme : optional(string, "http")
      tlsConfig : optional(map(string), {})
      path : optional(string, "/metrics")
      metricRelabeling : optional(list(string), [])
      relabelings : optional(list(string), [])
    }), {})
  })
  default = {}
}


variable "service" {
  description = "Configure a service resource e.g., to allow scraping metrics via prometheus-operator serviceMonitor."
  type = object({
    enabled : optional(bool, false)
    labels : optional(map(string), {})
    annotations : optional(map(string), {})
    clusterIP : optional(string, "")
    externalIPs : optional(list(string), [])
    loadBalancerIP : optional(string, "")
    loadBalancerSourceRanges : optional(list(string), [])
    type : optional(string, "ClusterIP")
    metrics : optional(object({
      nodePort : optional(string, "")
    }), null),
    additionalPorts : optional(list(string), [])
  })
  default = {}
}

variable "schedulerName" {
  description = "The name of the scheduler to use."
  type        = string
  default     = null
}


variable "securityContext" {
  description = "Runner container security context."
  type = object({
    allowPrivilegeEscalation : optional(bool, false)
    readOnlyRootFilesystem : optional(bool, false)
    runAsNonRoot : optional(bool, true)
    privileged : optional(bool, false)
    capabilities : optional(object({
      add : optional(list(string), [])
      drop : optional(list(string), [])
    }), { drop : ["ALL"] })
  })
  default = {}
}

variable "strategy" {
  description = "Configure update strategy for multi-replica deployments"
  type = object({
    type = string
    rollingUpdate = optional(object({
      maxSurge       = string
      maxUnavailable = string
    }), null)
  })
  default = null

  validation {
    condition     = var.strategy != null ? contains(["RollingUpdate", "Recreate"], var.strategy.type) : true
    error_message = "Invalid deployment strategy type. Allowed values are 'RollingUpdate' or 'Recreate'."
  }
}

variable "podSecurityContext" {
  description = "Runner ecurity context for the whole POD."
  type = object({
    runAsUser : optional(number, 100)
    runAsGroup : optional(number, 65533)
    fsGroup : optional(number, 65533)
    supplementalGroups : optional(list(number), [65533])
  })
  default = {}
}


variable "resources" {
  description = "The CPU and memory resources given to the runner."
  default     = null
  type = object({
    requests = optional(object({
      cpu               = optional(string)
      memory            = optional(string)
      ephemeral-storage = optional(string)
    })),
    limits = optional(object({
      cpu               = optional(string)
      memory            = optional(string)
      ephemeral-storage = optional(string)
    }))
  })
}

variable "affinity" {
  description = "Affinity for runner pod assignment."
  default     = {}
  type = object({
    nodeAffinity : optional(object({
      preferredDuringSchedulingIgnoredDuringExecution : optional(list(object({
        weight : number
        preference : object({
          matchExpressions : optional(list(object({
            key : string
            operator : string
            values : list(string)
          })))
          matchFields : optional(list(object({
            key : string
            operator : string
            values : list(string)
          })))
        })
      })), null)
      requiredDuringSchedulingIgnoredDuringExecution : optional(list(object({
        nodeSelectorTerms : object({
          matchExpressions : optional(object({
            key : string
            operator : string
            values : list(string)
          }))
          matchFields : optional(object({
            key : string
            operator : string
            values : list(string)
          }))
        })
      })), null)
    }), null)

    podAffinity : optional(object({
      preferredDuringSchedulingIgnoredDuringExecution : optional(list(object({
        podAffinityTerm : object({
          weight : number
          topology_key : string
          namespaces : optional(list(string))
          labelSelector : optional(object({
            matchExpressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            matchLabels : optional(list(string))
          }))
          namespaceSelector : optional(object({
            matchExpressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            matchLabels : optional(list(string))
          }))
        })
      })), null)
      requiredDuringSchedulingIgnoredDuringExecution : optional(list(object({
        topology_key : string
        namespaces : optional(list(string))
        labelSelector : optional(object({
          matchExpressions : optional(list(object({
            key : string
            operator : string
            values : list(string)
          })))
          matchLabels : optional(list(string))
        }))
        namespaceSelector : optional(object({
          matchExpressions : optional(list(object({
            key : string
            operator : string
            values : list(string)
          })))
          matchLabels : optional(list(string))
        }))
      })), null)
    }), null)

    podAntiAffinity : optional(object({
      preferredDuringSchedulingIgnoredDuringExecution : optional(list(object({
        podAffinityTerm : object({
          weight : number
          topology_key : string
          namespaces : optional(list(string))
          labelSelector : optional(object({
            matchExpressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            matchLabels : optional(list(string))
          }))
          namespaceSelector : optional(object({
            matchExpressions : optional(list(object({
              key : string
              operator : string
              values : list(string)
            })))
            matchLabels : optional(list(string))
          }))
        })
      })), null)
      requiredDuringSchedulingIgnoredDuringExecution : optional(list(object({
        topology_key : string
        namespaces : optional(list(string))
        labelSelector : optional(object({
          matchExpressions : optional(list(object({
            key : string
            operator : string
            values : list(string)
          })))
          matchLabels : optional(list(string))
        }))
        namespaceSelector : optional(object({
          matchExpressions : optional(list(object({
            key : string
            operator : string
            values : list(string)
          })))
          matchLabels : optional(list(string))
        }))
      })), null)
    }), null)
  }) //affinity
}

variable "topologySpreadConstraints" {
  description = "TopologySpreadConstraints for pod assignment."
  default     = null
  type = list(object({
    maxSkew : number
    minDomain : optional(number, 1)
    topologyKey : string
    whenUnsatisfiable : string
    labelSelector : object({
      matchLabels : optional(map(string), {})
      matchExpressions : optional(list(object({
        key : string
        operator : string
        values : list(string)
      })), [])
    })
    matchLabelKeys : optional(list(string), null)
    nodeAffinityPolicy : optional(string, null)
    nodeTaintsPolicy : optional(string, null)
  }))
  // add validation for the nodeAffinityPolicy and nodeTaintsPolicy
  validation {
    condition = var.topologySpreadConstraints != null ? alltrue([
      for t in var.topologySpreadConstraints : t.nodeAffinityPolicy != null ? contains(["Honor", "Ignore"], t.nodeAffinityPolicy) : true
    ]) : true
    error_message = "Must be one of: \"Honor\", \"Ignore\"."
  }
  validation {
    condition = var.topologySpreadConstraints != null ? alltrue([
      for t in var.topologySpreadConstraints : t.nodeTaintsPolicy != null ? contains(["Honor", "Ignore"], t.nodeTaintsPolicy) : true
    ]) : true
    error_message = "Must be one of: \"Honor\", \"Ignore\"."
  }
}

variable "tolerations" {
  description = "List of node taints to tolerate by the runner PODs."
  default     = []
  type = list(object({
    key : string
    operator : string
    value : string
    effect : string
  }))
  validation {
    condition = alltrue([
      for t in var.tolerations : contains(["Equal", "Exists", "NotExists"], t.operator)
    ])
    error_message = "Must be one of: \"Equal\", \"Exists\", \"NotExists\"."
  }
  validation {
    condition = alltrue([
      for t in var.tolerations : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], t.effect)
    ])
    error_message = "Must be one of: \"NoSchedule\", \"PreferNoSchedule\", \"NoExecute\"."
  }
}

variable "nodeSelector" {
  description = "A map of node selectors to apply to the pods"
  default     = {}
  type        = map(string)
}

variable "envVars" {
  description = "Configure environment variables that will be present when the registration command runs."
  type = map(object({
    name : string
    value : string
  }))
  default = null
}

variable "extraEnv" {
  description = "Extra environment variables to be added to the runner pods."
  type        = map(string)
  default     = {}
}

variable "extraEnvFrom" {
  description = "Additional environment variables from other data sources (k8s secrets)."
  type = map(object({
    secretKeyRef : object({
      name : string
      key : string
    })
  }))
  default = {}
}

variable "hostAliases" {
  description = "List of hosts and IPs that will be injected into the pod's hosts file."
  type = list(object({
    ip : string
    hostnames : list(string)
  }))
  default = []
}

variable "deploymentAnnotations" {
  description = "Annotations to be added to the runner deployment."
  type        = map(string)
  default     = {}
}

variable "deploymentLabels" {
  description = "Labels to be added to the runner deployment."
  type        = map(string)
  default     = {}
}

variable "deploymentLifecycle" {
  description = "Configure the lifecycle of the runner deployment."
  type        = map(any)
  default     = {}
}



variable "hpa" {
  description = "Horizontal Pod Autoscaling with API limited to metrics specification only (api/version: autoscaling/v2)."
  type = object({
    minReplicas = number
    maxReplicas = number
    behavior = object({
      scale_up = object({
        stabilizationWindowSeconds = number
        selectPolicy               = string
        policies = list(object({
          type          = string
          value         = number
          periodSeconds = number
        }))
      })
      scaleDown = object({
        stabilizationWindowSeconds = number
        selectPolicy               = string
        policies = list(object({
          type           = string
          value          = number
          period_seconds = number
        }))
      })
    })
    metrics = list(object({
      type = string

      resource = optional(object({
        name = string
        target = object({
          type               = string
          averageUtilization = optional(number)
          averageValue       = optional(string)
          value              = optional(string)
        })
      }))
      pods = optional(object({
        metric = object({
          name = string
          selector = optional(object({
            matchLabels = optional(map(string))
          }))
        })
        target = object({
          type         = string
          averageValue = optional(string)
          value        = optional(string)
        })
      }))
      object = optional(object({
        metric = object({
          name = string
          selector = optional(object({
            matchLabels = optional(map(string))
          }))
        })
        describedObject = object({
          apiVersion = string
          kind       = string
          name       = string
        })
        target = object({
          type         = string
          averageValue = optional(string)
          value        = optional(string)
        })
      }))
      external = optional(object({
        metric = object({
          name = string
          selector = optional(object({
            matchLabels = optional(map(string))
          }))
        })
        target = optional(object({
          type         = string
          averageValue = optional(string)
          value        = optional(string)
        }))
      }))
      containerResource = optional(object({
        name      = string
        container = string
        target = object({
          type               = string
          averageUtilization = optional(number)
          averageValue       = optional(string)
          value              = optional(string)
        })
      }))
    }))
  })
  default = null
}


variable "priorityClassName" {
  description = "Configure priorityClassName for the runner pod. If not set, globalDefault priority class is used."
  type        = string
  default     = ""
}

variable "secrets" {
  description = " Secrets to be additionally mounted to the containers."
  type = list(object({
    name = string
    items = optional(list(object({
      key  = string
      path = string
    })))
  }))
  default = []
}

variable "automountServiceAccountToken" {
  description = "Automount service account token in the deployment.."
  type        = bool
  default     = false
}

// TODO: add static typing when it's going to be clear
variable "configMaps" {
  description = "Additional ConfiMaps to be mounted."
  type        = map(any)
  default     = null
}


variable "volumeMounts" {
  description = "Additional volumeMounts to add to the runner container."
  type = list(object({
    mountPath : string
    name : string
    mountPropagation : optional(string)
    readOnly : optional(bool, false)
    subPath : optional(string)
    subPathExpr : optional(string)
  }))
  default = []
}


variable "volumes" {
  description = "List of volumes to be attached to the pod"
  type = list(object({
    name      = string
    type      = string
    options   = map(string)
    localPath = optional(string)
    hostPath = optional(object({
      path = string
      type = optional(string)
    }))
    configMap = optional(object({
      name = string
      items = optional(list(object({
        key  = string
        path = string
      })))
    }))
    secret = optional(object({
      secretName = string
      items = optional(list(object({
        key  = string
        path = string
      })))
    }))
    emptyDir = optional(object({
      medium    = optional(string)
      sizeLimit = optional(string)
    }))
  }))
  default = []
}

variable "extraObjects" {
  description = "Additional k8s objects to be created."
  type        = list(map(any))
  default     = []
}


variable "runners" {
  type = list(object({
    name     = string
    executor = optional(string, "kubernetes")
    shell    = optional(string, "bash")
    url      = optional(string, "https://gitlab.com/") //TODO: values.gitlabUrl? The GitLab Server URL (with protocol) that want to register the runner against

    environment = optional(list(string), null)
    cache_dir   = optional(string)

    kubernetes = object({
      namespace       = string
      pod_labels      = optional(map(string), null) // job's pods labels
      pod_annotations = optional(map(string), null) // job's annotations

      poll_interval : optional(number, 3)  //How frequently, in seconds, the runner will poll the Kubernetes pod it has just created to check its status
      poll_timeout : optional(number, 180) //The amount of time, in seconds, that needs to pass before the runner will time out attempting to connect to the container it has just created. 

      image                            = optional(string) //The image to run jobs with.
      helper_image                     = optional(string) //The default helper image used to clone repositories and upload artifacts.
      helper_image_flavor              = optional(string) //Sets the helper image flavor (alpine, alpine3.16, alpine3.17, alpine3.18, alpine3.19, alpine-latest, ubi-fips or ubuntu). Defaults to alpine. The alpine flavor uses the same version as alpine3.19.
      helper_image_autoset_arch_and_os = optional(string) //Uses the underlying OS to set the Helper Image ARCH and OS.

      image_pull_secrets = optional(list(string), null)       // An array of items containing the Kubernetes docker-registry secret names used to authenticate Docker image pulling from private registries.
      pull_policy        = optional(string, "if-not-present") //The Kubernetes pull policy for the runner container. Defaults to if-not-present.



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
        host_path = optional(list(object({
          name       = string
          mount_path = string
          host_path  = string
          read_only  = optional(bool, false)
        })), null)
      }), null)
    })

    // start of cache block
    cache = optional(object({
      Type                   = optional(string, "gcs")
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
      for r in var.runners : r.cache != null ? contains(["s3", "gcs", "azure"], r.cache.Type) : true
    ])
    error_message = "Cache type must be one of 's3', 'gcs', or 'azure'."
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

  validation {
    condition = alltrue([
      for r in var.runners : contains(["never", "if-not-present", "always"], r.kubernetes.pull_policy)
    ])
    error_message = "Must be of values: \"never\", \"if-not-present\", \"always\"."
  }
}

variable "configPath" {
  description = "Absolute path for an existing runner configuration file"
  type        = string
  default     = ""
}
