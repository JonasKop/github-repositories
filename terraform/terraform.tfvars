repositories = {
  // 3rd party services config
  home-assistant-configuration : {
    description : "Home assistant configuration."
  }
  zigbee2mqtt-configuration : {
    description : "Zigbee2MQTT configuration."
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
