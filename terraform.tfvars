imagePullPolicy = "Always"

imagePullSecrets = [
  {
    name = "gitlab-registry"
  }
]

runners = [
  {
    name  = "runner1"
    shell = "sh"
    kubernetes = {
      namespace = "gitlab-runner"
    }
    cache = {
      Type   = "local"
      Path   = "/cache"
      Shared = true
    }

  },
  {
    name  = "standard"
    shell = "bash"


    environment = [
      "ENV1=true",
      "ENV2=cat and dog"
    ]
    kubernetes = {
      namespace = "gitlab-runner"

      pod_labels = {
        app            = "jobber"
        commitShortSHA = "$CI_COMMIT_SHORT_SHA"
        commitTag      = "$CI_COMMIT_TAG"
        gitUserLogin   = "$GITLAB_USER_LOGIN"
        jobId          = "$CI_JOB_ID"
        jobName        = "$CI_JOB_NAME"
        pipelineId     = "$CI_PIPELINE_ID"
        project        = "$CI_PROJECT_NAME"
      } //pod labels

      pod_annotations = {
        "cluster-autoscaler.kubernetes.io/safe-to-evict" = "false"
      }


      volumes = {
        empty_dir = [{
          name       = "docker-certs"
          mount_path = "/certs/client"
          medium     = "Memory"
          size_limit = "10Mi"
        }]
      }




    }

    cache = {
      Type                   = "gcs"
      Path                   = "cache"
      Shared                 = true
      MaxUploadedArchiveSize = 0
      gcs = {
        BucketName = "opl-navio-services-cache-gitlab-runner-stg"
      }
    }

    // Job's pods affinity
    affinity = {
      node_affinity = {
        preferred_during_scheduling_ignored_during_execution = [
          {
            weight = 100
            preference = {
              match_expressions = [
                {
                  key      = "opl.navio.services/devopsLoad"
                  operator = "In"
                  values   = ["true"]
                }
              ]
            }
          }
        ]
      }
    } //afinity




  } //runner standard
]

