#!/bin/bash

# Optional argument
engine=${1-"podman"}

# Container Name
name="docker-registry-tools"

# Options
# Use --no-cache when e.g. updating docker-entrypoint.sh and images don't get updated as they should
opts=""
#opts="--no-cache"

# Mandatory Tag
#tag=$(cat ./tag.txt)
tag=$(date +%Y%m%d)

# Select Dockerfile
buildfile="Dockerfile"

# Select Platform
platform="linux/amd64"
#platform="linux/arm64/v8"

# Check if they are set
if [[ ! -v name ]] || [[ ! -v tag ]]
then
   echo "Both Container Name and Tag Must be Set" !
fi

# Copy requirements into the build context
# cp <myfolder> . -r docker build . -t  project:latest

# Prefer Podman over Docker
if [[ -n $(command -v podman) ]] && [[ "${engine}" == "podman" ]]
then
    # Use Podman and ./build/ folder to build the image
    podman build ${opts} -f ${buildfile} . -t ${name}:${tag} -t ${name}:latest
elif [[ -n $(command -v docker) ]] && [[ "${engine}" == "docker" ]]
then
    # Use Docker and ./build/ folder to build the image
    docker build ${opts} -f ${buildfile} . -t ${name}:${tag} -t ${name}:latest
else
    # Error
    echo "Neither Podman nor Docker could be found and/or the specified Engine <$engine> was not valid. Aborting !"
fi

# Upload to local Registry
source ./upload_local_registry.sh
