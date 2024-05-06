#!/bin/bash

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Tag
SKOPEO_TAG=${2-"latest"}

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
if [[ "${SKOPEO_TAG}" == "latest" ]]
then
   SKOPEO_BASE_URL="https://github.com/lework/skopeo-binary/releases/latest/download"
else
   SKOPEO_BASE_URL="https://github.com/lework/skopeo-binary/releases/download/${SKOPEO_TAG}"
fi

# Echo
echo "Base URL Set to: ${SKOPEO_BASE_URL}"

# Skopeo download links
SKOPEO_DOWNLOAD_URL="${SKOPEO_BASE_URL}/skopeo-linux-${ARCHITECTURE}"

# Echo
echo "Download URL Set to: ${SKOPEO_DOWNLOAD_URL}"

# Create Directory for Skopeo Executables (if it doesn't exist yet)
mkdir -p "/opt/skopeo"

# Fetch Packages
echo "Fetching Package for skopeo: ${SKOPEO_DOWNLOAD_URL}"
curl -sS -L --output-dir /opt/skopeo -o skopeo --create-dirs "${SKOPEO_DOWNLOAD_URL}"

# Make them executable
chmod +x /opt/skopeo/*
