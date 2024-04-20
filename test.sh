#!/bin/bash

# Container Name
name="docker-registry-tools"

# Containers Configuration Folder to Map
#containersconfigfolder="${HOME}/.config/skopeo"
containersconfigfolder="./containers"

# Load the Environment Variables into THIS Script
#shdoteven --env ".env"
eval "$(shdotenv --env .env || echo \"exit $?\")"

# Terminate and Remove Existing Containers if Any
podman stop --ignore ${name}
podman rm --ignore ${name}

# Run Image with Infinite Loop to prevent it from automatically terminating
#podman run -d --name=${name} "localhost/docker-registry-tools:latest" bash -c "trap INT; trap TERM; while [ true ]; do sleep 1; done"
#podman run -d --name=${name} "localhost/docker-registry-tools:latest"
podman run -d --name=${name} --env-file "./.env" -v "${containersconfigfolder}:/etc/containers" "localhost/docker-registry-tools:latest"

# Manual Debugging
#podman exec -it "${name}" /bin/bash

# Sync One Image
#podman exec "${name}" skopeo sync --scoped --src docker --dest docker --all ghcr.io/home-assistant/home-assistant:stable "${LOCAL_MIRROR}" # Double Quotes means that the value from the HOST Shell will be used
#podman exec "${name}" skopeo sync --scoped --src "docker" --dest "docker" --all "ghcr.io/home-assistant/home-assistant:stable" '${LOCAL_MIRROR}'    # Single Quotes means that the value from the CONTAINER Shell will be used
#podman exec "${name}" skopeo sync --scoped --src "docker" --dest "docker" --all "ghcr.io/home-assistant/home-assistant:stable" '${LOCAL_MIRROR}'    # Single Quotes means that the value from the CONTAINER Shell will be used

# Build Commands Args for use with Variable Expansion
eargs=()
eargs+=("--scoped")
eargs+=("--src")
eargs+=("docker")
eargs+=("--dest")
eargs+=("docker")
eargs+=("--all")
eargs+=("ghcr.io/home-assistant/home-assistant:stable")
eargs+=("${LOCAL_MIRROR}")

# Sync One Image
#podman exec "${name}" bash -c "skopeo sync --scoped --src docker --dest docker --all \"ghcr.io/home-assistant/home-assistant:stable\" \"${LOCAL_MIRROR}\""
podman exec "${name}" bash -c "skopeo sync ${eargs[*]}"
