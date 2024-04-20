#!/bin/bash

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Version
REGCLIENT_VERSION=${2-"latest"}

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
   REGCLIENT_BASE_URL="https://github.com/regclient/regclient/releases/download/${REGCLIENT_TAG}"
else
   REGCLIENT_BASE_URL="https://github.com/regclient/regclient/releases/latest/download"
fi

# Echo
echo "Base URL Set to: ${REGCLIENT_BASE_URL}"

# regctl download links
REGCTL_DOWNLOAD_URL="${REGCLIENT_BASE_URL}/regctl-linux-${ARCHITECTURE}"

# rebgot download links
REGBOT_DOWNLOAD_URL="${REGCLIENT_BASE_URL}/regbot-linux-${ARCHITECTURE}"

# regsync download links
REGSYNC_DOWNLOAD_URL="${REGCLIENT_BASE_URL}/regsync-linux-${ARCHITECTURE}"

# Create Directory for RegClient Executables
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
