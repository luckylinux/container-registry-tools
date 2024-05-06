#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing ${scriptpath}/${relativepath}); fi

# Load Configuration
libpath=$(readlink --canonicalize-missing "${toolpath}/includes")
source ${libpath}/functions.sh


# Optional argument
engine=${1-"podman"}

# Container Name
containername="container-registry-tools"

# Container Image
containerimage="container-registry-tools:debian-latest"

# Containers Configuration Folder to Map
#containersconfigfolder="${HOME}/.config/skopeo"
containersconfigfolder="./containers"

# Load the Environment Variables into THIS Script
#shdoteven --env ".env"
eval "$(shdotenv --env .env || echo \"exit $?\")"

# Terminate and Remove Existing Containers if Any
${engine} stop --ignore ${containername}
${engine} rm --ignore ${containername}

# Run Image with Infinite Loop to prevent it from automatically terminating
#${engine} run -d --name=${containername} "${containerimage}" bash -c "trap INT; trap TERM; while [ true ]; do sleep 1; done"
#${engine} run -d --name=${containername} "${containerimage}"
${engine} run -d --name=${containername} --env-file "./.env" -v "${containersconfigfolder}:/etc/containers" localhost:5000/local/"${containerimage}"

# Manual Debugging
#${engine} exec -it "${containername}" /bin/bash

# Sync One Image
#${engine} exec "${containername}" skopeo sync --scoped --src docker --dest docker --all ghcr.io/home-assistant/home-assistant:stable "${LOCAL_MIRROR}" # Double Quotes means that the value from the HOST Shell will be used
#${engine} exec "${containername}" skopeo sync --scoped --src "docker" --dest "docker" --all "ghcr.io/home-assistant/home-assistant:stable" '${LOCAL_MIRROR}'    # Single Quotes means that the value from the CONTAINER Shell will be used
#${engine} exec "${containername}" skopeo sync --scoped --src "docker" --dest "docker" --all "ghcr.io/home-assistant/home-assistant:stable" '${LOCAL_MIRROR}'    # Single Quotes means that the value from the CONTAINER Shell will be used

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
${engine} exec "${containername}" bash -c "skopeo sync --scoped --src docker --dest docker --all \"ghcr.io/home-assistant/home-assistant:stable\" \"${LOCAL_MIRROR}\""
${engine} exec "${containername}" bash -c "skopeo sync ${eargs[*]}"
