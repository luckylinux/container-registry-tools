#!/bin/bash

# Container Name
name="docker-registry-tools"

# Containers Configuration Folder to Map
containersconfigfolder="./containers"

# Load the Environment Variables into THIS Script
eval "$(shdotenv --env .env || echo \"exit $?\")"

# Terminate and Remove Existing Containers if Any
podman stop --ignore ${name}
podman rm --ignore ${name}

# Run Image with Infinite Loop to prevent it from automatically terminating
podman run -d --name=${name} --env-file "./.env" -v "${containersconfigfolder}:/etc/containers" "localhost/docker-registry-tools:latest"

# Sync One Image
#podman exec "${name}" skopeo sync --scoped --src docker --dest docker --all ghcr.io/home-assistant/home-assistant:stable "${LOCAL_MIRROR}" # Double Quotes means that the value from the HOST Shell will be used
#podman exec "${name}" skopeo sync --scoped --src "docker" --dest "docker" --all "ghcr.io/home-assistant/home-assistant:stable" '${LOCAL_MIRROR}'    # Single Quotes means that the value from the CONTAINER Shell will be used
