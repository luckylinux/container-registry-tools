#!/bin/bash

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Tag
REGCLIENT_TAG=${2-"latest"}

# Install Path
REGCLIENT_PATH="/opt/regclient"

# Cache Path
REGCLIENT_CACHE_PATH="/var/lib/installer/regclient"

# Repository
REGCLIENT_REPOSITORY="regclient/regclient"

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
if [[ "${REGCLIENT_TAG}" == "latest" ]]
then
   # Define Base URL
   REGCLIENT_BASE_URL="https://github.com/${REGCLIENT_REPOSITORY}/releases/latest/download"

   # Retrieve what Version the "latest" tag Corresponds to
   REGCLIENT_VERSION=$(curl -H "Accept: application/vnd.github.v3+json" -sS  "https://api.github.com/repos/${REGCLIENT_REPOSITORY}/tags" | jq -r '.[0].name')
else
   # Define Base URL
   REGCLIENT_BASE_URL="https://github.com/${REGCLIENT_REPOSITORY}/releases/download/${REGCLIENT_TAG}"

   # Version is the same as the Tag
   REGCLIENT_VERSION=${REGCLIENT_TAG}
fi

# Regctl download Filename
REGCTL_PACKAGE_FILENAME="regctl-linux-${ARCHITECTURE}"

# Regctl download links
REGCTL_PACKAGE_URL="${REGCLIENT_BASE_URL}/${CRANE_PACKAGE_FILENAME}"


# Echo
echo "Download URL Set to: ${CRANE_PACKAGE_URL}"
echo "Checksum URL Set to: ${CRANE_CHECKSUM_URL}"

# Create Directory for Crane Executables (if it doesn't exist yet)
mkdir -p "/opt/regclient"



# regctl download links
REGCTL_DOWNLOAD_URL="${REGCLIENT_BASE_URL}/regctl-linux-${ARCHITECTURE}"

# rebgot download links
REGBOT_DOWNLOAD_URL="${REGCLIENT_BASE_URL}/regbot-linux-${ARCHITECTURE}"

# regsync download links
REGSYNC_DOWNLOAD_URL="${REGCLIENT_BASE_URL}/regsync-linux-${ARCHITECTURE}"

# Create Directory for RegClient Executables (if it doesn't exist yet)
mkdir -p "/opt/regclient"

# Fetch Packages
echo "Fetching Package for regctl: ${REGCTL_DOWNLOAD_URL}"
curl -sS -L --output-dir /opt/regclient -o regctl --create-dirs "${REGCTL_DOWNLOAD_URL}"

echo "Fetching Package for regbot: ${REGBOT_DOWNLOAD_URL}"
curl -sS -L --output-dir /opt/regclient -o regbot --create-dirs "${REGBOT_DOWNLOAD_URL}"

echo "Fetching Package for regsync: ${REGSYNC_DOWNLOAD_URL}"
curl -sS -L --output-dir /opt/regclient -o regsync --create-dirs "${REGSYNC_DOWNLOAD_URL}"

# Make them executable
chmod +x /opt/regclient/*
