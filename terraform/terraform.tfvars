repositories = {
  // 3rd party services config
  home-assistant-configuration : {
    description : "Home assistant configuration."
  }
  mosquitto-configuration : {
    description : "Mosquitto configuration."
  }

  // Infra
  argocd-applications : {
    description : "Argo CD applications."
  }
  infrastructure : {
    description : "Infrastructure configuration."
  }
  github-repositories : {
    description : "Github repositories configuration."
    statusCheck : true
    secrets : {
      TF_API_TOKEN : "TERRAFORM_CLOUD_TOKEN"
      DOPPLER_TOKEN : "DOPPLER_TOKEN"
      ADMIN_GITHUB_TOKEN : "GITHUB_ADMIN_TOKEN"
    }
  }

  // Tools
  external-secrets-transformer : {
    description : "Kubernetes tool which transforms a secret into an external secret."
  }

  // Github Actions
  custom-github-actions : {
    description : "Custom Github Actions usable in github workflows."
  }
}
