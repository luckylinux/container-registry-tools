#!/bin/bash

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Tag
SUPERCRONIC_TAG=${2-"latest"}

# Install Path
SUPERCRONIC_PATH="/opt/supercronic"

# Cache Path
SUPERCRONIC_CACHE_PATH="/var/lib/installer/supercronic"

# Repository
SUPERCRONIC_REPOSITORY="aptible/supercronic"

# Architecture Mapping
if [ "${TARGETPLATFORM}" = "linux/amd64" ]
then
   ARCHITECTURE="amd64"
elif [ "${TARGETPLATFORM}" = "linux/arm64/v8" ]
then
   ARCHITECTURE="arm64";
else
   echo "Architecture ${TARGETPLATFORM} received"
fi

# Tag or Latest have different URL Structure
if [[ "${SUPERCRONIC_TAG}" == "latest" ]]
then
   # Define Base URL
   SUPERCRONIC_BASE_URL="https://github.com/${SUPERCRONIC_REPOSITORY}/releases/latest/download"

   # Retrieve what Version the "latest" tag Corresponds to
   SUPERCRONIC_VERSION=$(curl -H "Accept: application/vnd.github.v3+json" -sS  "https://api.github.com/repos/${SUPERCRONIC_REPOSITORY}/tags" | jq -r '.[0].name')
else
   # Define Base URL
   SUPERCRONIC_BASE_URL="https://github.com/${SUPERCRONIC_REPOSITORY}/releases/download/${SUPERCRONIC_TAG}"

   # Version is the same as the Tag
   SUPERCRONIC_VERSION=${SUPERCRONIC_TAG}
fi

# Echo
echo "Base URL Set to: ${SUPERCRONIC_BASE_URL}"

# Supercronic download links
SUPERCRONIC_DOWNLOAD_URL="${SUPERCRONIC_BASE_URL}/supercronic-linux-${ARCHITECTURE}"

# Echo
echo "Download URL Set to: ${SUPERCRONIC_DOWNLOAD_URL}"

# Create Directory for Supercronic Executables (if it doesn't exist yet)
mkdir -p "/opt/supercronic"

# Fetch Packages
echo "Fetching Package for supercronic: ${SUPERCRONIC_DOWNLOAD_URL}"
curl -sS -L --output-dir /opt/supercronic -o supercronic --create-dirs "${SUPERCRONIC_DOWNLOAD_URL}"

# Make them executable
chmod +x /opt/supercronic/*

# Also create a Configuration Folder in /etc/supercronic
mkdir -p /etc/supercronic
