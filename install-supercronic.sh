#!/bin/bash

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Tag
SUPERCRONIC_TAG=${2-"latest"}

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
   SUPERCRONIC_BASE_URL="https://github.com/aptible/supercronic/releases/latest/download"
else
   SUPERCRONIC_BASE_URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_TAG}"
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
