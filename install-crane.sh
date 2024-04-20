#!/bin/bash

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Tag
CRANE_TAG=${2-"latest"}

# Architecture Mapping
if [ "${TARGETPLATFORM}" = "linux/amd64" ]
then
   ARCHITECTURE="x86_64"
elif [ "${TARGETPLATFORM}" = "linux/arm64/v8" ]
then
   ARCHITECTURE="arm64";
else
   echo "Architecture ${TARGETPLATFORM} received"
fi

# Tag or Latest have different URL Structure
if [[ "${CRANE_TAG}" == "latest" ]]
then
   CRANE_BASE_URL="https://github.com/google/go-containerregistry/releases/latest/download"
else
   CRANE_BASE_URL="https://github.com/google/go-containerregistry/releases/download/${CRANE_TAG}"
fi

# Echo
echo "Base URL Set to: ${CRANE_BASE_URL}"

# Crane download links
CRANE_DOWNLOAD_URL="${CRANE_BASE_URL}/go-containerregistry_Linux_${ARCHITECTURE}.tar.gz"

# Echo
echo "Download URL Set to: ${CRANE_DOWNLOAD_URL}"

# Create Directory for Crane Executables (if it doesn't exist yet)
mkdir -p "/opt/crane"

# Fetch Packages
echo "Fetching Package for crane: ${CRANE_DOWNLOAD_URL}"
curl -sS -L --output-dir /tmp -o crane.tar.gz --create-dirs "${CRANE_DOWNLOAD_URL}"

# Decompress the Archive
tar xf /tmp/crane.tar.gz -C /opt/crane

# Remove the temporary Archive
rm -f /tmp/crane.tar.gz

# Make them executable
chmod +x /opt/crane/*
