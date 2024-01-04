#!/bin/bash

set -eu

# Require environment variables
export TF_CLOUD_ORGANIZATION=$TF_CLOUD_ORGANIZATION \
    TF_WORKSPACE=$TF_WORKSPACE

# Get git repo path and cd to it
gitRepoPath=$(git rev-parse --show-toplevel)
cd $gitRepoPath

# Get terraform state in json format
tfstate=$(cd terraform && terraform show -json)

# Get all repositories ssh clone urls
sshUrls=$(echo "$tfstate" | yq '.values.root_module | .[] | .[] | select(.type == "github_repository") | .values.ssh_clone_url')

# cd out of the repository
cd ..

# Clone all repositories
for sshUrl in $sshUrls; do
    repoName=$(echo $sshUrl | sed 's/^.*JonasKop\///' | sed 's/\.git$//')
    if [ ! -d "$repoName" ]; then
        git clone "$sshUrl" "$repoName"
    else
        echo "Repository $repoName already cloned, skipping..."
    fi
done
