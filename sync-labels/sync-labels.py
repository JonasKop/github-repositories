#!/usr/bin/env python3
import os, subprocess, json, yaml, requests


# Get github repositories from terraform state
def getTerraformRepositories():
    # Get terraform state in json format
    terraformStateString = subprocess.check_output(
        ["terraform", "-chdir=../terraform" ,"show", "-json"]
    ).decode("utf-8")
    terraformState = json.loads(terraformStateString)

    # Fetch github repository names from terraform state
    terraformStateRepositories = [
        x
        for x in terraformState["values"]["root_module"]["resources"]
        if x["type"] == "github_repository"
    ]
    return [x["index"] for x in terraformStateRepositories]


# Read labels from config file
def readLabelsConfig():
    file = open("labels.yaml", "r")
    content = file.read()
    file.close()
    return yaml.safe_load(content)


# Send an api request to githubs api
def githubApiRequest(method, path, body=None):
    return requests.request(
        method,
        f"https://api.github.com{path}",
        headers={
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "Authorization": f"Bearer {githubToken}",
        },
        json=body,
    )


# Main function
if __name__ == "__main__":
    # Get github repositories
    repositories = getTerraformRepositories()
    # Get labels from config
    labels = readLabelsConfig()

    # Define constants
    githubOwner = "jonaskop"
    githubToken = os.environ["GITHUB_TOKEN"]

    # Loop over github repositories
    for repo in repositories:
        print(f"Inspecting repo: {repo}")

        # List labels in repository
        response = githubApiRequest("GET", f"/repos/{githubOwner}/{repo}/labels")
        repoLabels = yaml.safe_load(response.text)

        # Loop over labels in config file to find which to create or update
        for label in labels:
            # Define label values
            name = label["name"]
            description = label["description"]
            color = label["color"]

            # Check if the label in the config file exists in the repository
            matchingRepoLabel = next(
                (repoLabel for repoLabel in repoLabels if repoLabel["name"] == name),
                None,
            )
            # If not exists in repository, create it
            if matchingRepoLabel == None:
                print(f"Create {name}")
                githubApiRequest(
                    "POST",
                    f"/repos/{githubOwner}/{repo}/labels",
                    {"name": name, "color": color, "description": description},
                )
            # If exists in repository, update it
            elif (
                matchingRepoLabel["color"] != color
                or matchingRepoLabel["description"] != description
            ):
                print(f"Update {name}")
                githubApiRequest(
                    "PATCH",
                    f"/repos/{githubOwner}/{repo}/labels/{name}",
                    {"color": color, "description": description},
                )

        # Loop over labels in repository to find which to delete
        for repoLabel in repoLabels:
            # Check if the label in the repository exists in the config file
            matchingLabel = next(
                (label for label in labels if label["name"] == repoLabel["name"]), None
            )
            # If label does not exist in config file, delete it
            if matchingLabel == None:
                name = repoLabel["name"]
                print(f"Delete {name}")
                githubApiRequest("DELETE", f"/repos/{githubOwner}/{repo}/labels/{name}")
