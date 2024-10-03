module "gitlab_runner_test" {
  source = "git::https://github.com/MaciekLeks/lazy-gitlab-runner-k8s-tf.git?ref=v0.2.0"
  helm_settings = {
    name      = "gitlab-runner-lazy-test"
    namespace = "my-gitlab-runner-namespace"
    version   = "0.68.1"
  }

  imagePullPolicy = "IfNotPresent"
  //imagePullSecrets = [{ name = "regcred" }]

  serviceAccount = {
    create = false
    name   = "my-runner-sa-name"
  }

  automountServiceAccountToken = true //runner needs to access K8s API

  runnerToken = "[redacted]"

  checkInterval                 = 2
  concurrent                    = 50
  terminationGracePeriodSeconds = 36000
  logLevel                      = "info"

  shutdown_timeout = 30

  livenessProbe = {
    initialDelaySeconds = 60
    timeoutSeconds      = 3
    periodSeconds       = 20
    failureThreshold    = 15
  }

  readinessProbe = {
    initialDelaySeconds = 60
    timeoutSeconds      = 3
    periodSeconds       = 20
    failureThreshold    = 15
  }

  gitlabUrl = "https://my-gitlab.my-domain.pl"

  metrics = {
    enabled = true
  }


  resources = {
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }

  podAnnotations = {
    "cluster-autoscaler.kubernetes.io/safe-to-evict" = "false"
  }

  podLabels = {
    "app.kubernetes.io/name"   = "gitlab-runner"
    "app.prometheus.io/scrape" = "true"
  }


  envVars = [{
    name  = "VAR1"
    value = "value1"
    }, {
    name  = "VAR2"
    value = "value2"
  }]

  runners = {
    name = "Kubernetes Runner - lazy-test"
    config = [{
      shell        = "bash"
      output_limit = 2600

      unhealthy_request_count = 30
      unhealthy_interval      = "180s"

      environment = ["ENV1=true", "ENV2=cat and dog"]

      cache = {
        Type   = "gcs"
        Path   = "cache"
        Shared = true
        gcs = {
          BucketName = "my-bucker-name"
        }
      }

      kubernetes = {
        namespace = "my-gitlab-runner-namespace"
        pod_annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict" = "false"
        }
        pod_labels = {
          jobId          = "$CI_JOB_ID"
          jobName        = "$CI_JOB_NAME"
          pipelineId     = "$CI_PIPELINE_ID"
          gitUserLogin   = "$GITLAB_USER_LOGIN"
          commitShortSHA = "$CI_COMMIT_SHORT_SHA"
          commitTag      = "$CI_COMMIT_TAG"
          project        = "$CI_PROJECT_NAME"
        }

        image        = "ubuntu:20.04"
        helper_image = "gitlab-org/gitlab-runner/gitlab-runner-helper:alpine3.19-x86_64-v17.3.1"


        poll_interval = 4
        poll_timeout  = 3600

        service_account = "my-executor-sa-name"

        volumes = {
          empty_dir = [{
            name       = "docker-certs"
            mount_path = "/certs/client"
            medium     = "Memory"
            size_limit = "10Mi"
          }]
        }

        cpu_request                          = "100m"
        cpu_request_overwrite_max_allowed    = "1400m"
        memory_request                       = "256Mi"
        memory_request_overwrite_max_allowed = "1Gi"

        cpu_limit_overwrite_max_allowed    = "3000m"
        memory_limit_overwrite_max_allowed = "2Gi"

        helper_cpu_request    = "150m"
        helper_memory_request = "256Mi"

        service_cpu_request    = "800m"
        service_memory_request = "1Gi"
        service_cpu_limit      = "3000m"
        service_memory_limit   = "2Gi"

        affinity = {
          node_affinity = {
            preferred_during_scheduling_ignored_during_execution = [
              {
                weight = 100
                preference = {
                  match_expressions = [
                    {
                      key      = "my-node-foo-label"
                      operator = "In"
                      values   = ["bar"]
                    }
                  ]
                }
              }
            ]
          }
        } //afinity
      }   //kubernetes
  }] }    //runners
}

