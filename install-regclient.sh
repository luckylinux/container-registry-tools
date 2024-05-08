#!/bin/bash

# Exit on Error
set -e

# Enable Verbose Output
# set -x

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

# Echo
echo "Base URL Set to: ${REGCLIENT_BASE_URL}"



# Regctl Package Filename
REGCTL_PACKAGE_FILENAME="regctl-linux-${ARCHITECTURE}"

# Regbot Package Filename
REGBOT_PACKAGE_FILENAME="regbot-linux-${ARCHITECTURE}"

# Regsync Package Filename
REGSYNC_PACKAGE_FILENAME="regbot-linux-${ARCHITECTURE}"

# Regclient Checksum File
REGCLIENT_CHECKSUM_FILENAME="metadata.tgz"

# Regctl Checksum Filename
REGCTL_CHECKSUM_FILENAME="${REGCTL_PACKAGE_FILENAME}.cyclonedx.json"

# Regbot Checksum Filename
REGBOT_CHECKSUM_FILENAME="${REGBOT_PACKAGE_FILENAME}.cyclonedx.json"

# Regsync Checksum Filename
REGSYNC_CHECKSUM_FILENAME="${REGSYNC_PACKAGE_FILENAME}.cyclonedx.json"


# regctl Package Download Link
REGCTL_PACKAGE_URL="${REGCLIENT_BASE_URL}/${REGCTL_PACKAGE_FILENAME}"

# rebgot Package Download Link
REGBOT_PACKAGE_URL="${REGCLIENT_BASE_URL}/${REGBOT_PACKAGE_FILENAME}"

# regsync Package Download Link
REGSYNC_PACKAGE_URL="${REGCLIENT_BASE_URL}/${REGSYNC_PACKAGE_FILENAME}"

# Regclient Checksum Download Link
REGCLIENT_CHECKSUM_URL="${REGCLIENT_BASE_URL}/${REGCLIENT_CHECKSUM_FILENAME}"



# Echo
echo "Regctl Package URL Set to: ${REGCTL_PACKAGE_URL}"
echo "Regbot Package URL Set to: ${REGBOT_PACKAGE_URL}"
echo "Regsync Package URL Set to: ${REGSYNC_PACKAGE_URL}"
echo "Checksum URL Set to: ${REGCLIENT_CHECKSUM_URL}"



# Create Directory for Regclient Executables (if it doesn't exist yet)
mkdir -p "${REGCLIENT_PATH}"

# Create a ${REGCLIENT_VERSION} subdirectory within ${REGCLIENT_CACHE_PATH}
mkdir -p "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}"



# By default must download
REGCTL_PACKAGE_DOWNLOAD=1
REGBOT_PACKAGE_DOWNLOAD=1
REGSYNC_PACKAGE_DOWNLOAD=1

REGCLIENT_CHECKSUM_DOWNLOAD=1




# Check if Checksum File exists in Cache
if [[ -f "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGCLIENT_CHECKSUM_FILENAME}" ]]
then
    # Checksum File exists
    REGCLIENT_CHECKSUM_DOWNLOAD=0
else
    # Download Checksum File
    echo "Downloading Checksum File for Regclient: ${REGCLIENT_CHECKSUM_URL}"
    curl -sS -L --output-dir "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}" -o "${REGCLIENT_CHECKSUM_FILENAME}" --create-dirs "${REGCLIENT_CHECKSUM_URL}"
fi

# Extract Checksum Archive
mkdir -p "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/checksum"
tar xf "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGCLIENT_CHECKSUM_FILENAME}" -C "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/checksum"




# Check if Regctl Package File exists in Cache
if [[ -f "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGCTL_PACKAGE_FILENAME}" ]]
then
   # Package File exists
   REGCTL_PACKAGE_DOWNLOAD=0
fi

# Check if need to re-download Regctl Package
if [[ ${REGCTL_PACKAGE_DOWNLOAD} -ne 0 ]]
then
   # Download Package File
   echo "Downloading Package for Regctl from ${REGCTL_PACKAGE_URL}"
   curl -sS -L --output-dir "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}" -o "${REGCTL_PACKAGE_FILENAME}" --create-dirs "${REGCTL_PACKAGE_URL}"
else
   # Echo
   echo "Using Cache for Regctl from ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGCTL_PACKAGE_FILENAME}"
fi



# Check if Regbot Package File exists in Cache
if [[ -f "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGBOT_PACKAGE_FILENAME}" ]]
then
   # Package File exists
   REGBOT_PACKAGE_DOWNLOAD=0
fi

# Check if need to re-download Regbot Package
if [[ ${REGBOT_PACKAGE_DOWNLOAD} -ne 0 ]]
then
   # Download Package File
   echo "Downloading Package for Regbot from ${REGBOT_PACKAGE_URL}"
   curl -sS -L --output-dir "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}" -o "${REGBOT_PACKAGE_FILENAME}" --create-dirs "${REGBOT_PACKAGE_URL}"
else
   # Echo
   echo "Using Cache for Regbot from ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGBOT_PACKAGE_FILENAME}"
fi



# Check if Regsync Package File exists in Cache
if [[ -f "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGSYNC_PACKAGE_FILENAME}" ]]
then
   # Package File exists
   REGSYNC_PACKAGE_DOWNLOAD=0
fi

# Check if need to re-download Regsync Package
if [[ ${REGSYNC_PACKAGE_DOWNLOAD} -ne 0 ]]
then
   # Download Package File
   echo "Downloading Package for Regsync from ${REGSYNC_PACKAGE_URL}"
   curl -sS -L --output-dir "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}" -o "${REGSYNC_PACKAGE_FILENAME}" --create-dirs "${REGSYNC_PACKAGE_URL}"
else
   # Echo
   echo "Using Cache for Regsync from ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGSYNC_PACKAGE_FILENAME}"
fi





# Expected File Checksum
#REGCTL_PACKAGE_EXPECTED_CHECKSUM=$(cat "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/checksum/${REGCTL_CHECKSUM_FILENAME}" | jq -r ".metadata.component.version" | sed -E "s|sha256:([0-9a-zA-Z]+).*?$|\1|g")
REGCTL_PACKAGE_EXPECTED_CHECKSUM=$(jq -r ".metadata.component.version" "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/checksum/${REGCTL_CHECKSUM_FILENAME}" | sed -E "s|sha256:([0-9a-zA-Z]+).*?$|\1|g")

# Calculate Actual Checksum
REGCTL_PACKAGE_ACTUAL_CHECKSUM=$(sha256sum "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGCTL_PACKAGE_FILENAME}" | head -c 64)

# Check if checksum is correct
REGCTL_PACKAGE_CHECK_CHECKSUM=$(echo "${REGCTL_PACKAGE_EXPECTED_CHECKSUM} ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGCTL_PACKAGE_FILENAME}" | sha256sum -c --status)

# If Checksum is invalid, exit
if [[ ${REGCTL_PACKAGE_CHECK_CHECKSUM} -ne 0 ]]
then
   echo "Checksum of Package Regctl is Invalid: expected ${REGCTL_PACKAGE_EXPECTED_CHECKSUM} for File ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGCTL_PACKAGE_FILENAME}, got ${REGCTL_PACKAGE_ACTUAL_CHECKSUM}"
   exit 9
fi


# Expected File Checksum
#REGBOT_PACKAGE_EXPECTED_CHECKSUM=$(cat "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/checksum/${REGBOT_CHECKSUM_FILENAME}" | jq -r ".metadata.component.version" | sed -E "s|sha256:([0-9a-zA-Z]+).*?$|\1|g")
REGBOT_PACKAGE_EXPECTED_CHECKSUM=$(jq -r ".metadata.component.version" "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/checksum/${REGBOT_CHECKSUM_FILENAME}" | sed -E "s|sha256:([0-9a-zA-Z]+).*?$|\1|g")

# Calculate Actual Checksum
REGBOT_PACKAGE_ACTUAL_CHECKSUM=$(sha256sum "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGBOT_PACKAGE_FILENAME}" | head -c 64)

# Check if checksum is correct
REGBOT_PACKAGE_CHECK_CHECKSUM=$(echo "${REGBOT_PACKAGE_EXPECTED_CHECKSUM} ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGBOT_PACKAGE_FILENAME}" | sha256sum -c --status)

# If Checksum is invalid, exit
if [[ ${REGBOT_PACKAGE_CHECK_CHECKSUM} -ne 0 ]]
then
   echo "Checksum of Package Regbot is Invalid: expected ${REGBOT_PACKAGE_EXPECTED_CHECKSUM} for File ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGBOT_PACKAGE_FILENAME}, got ${REGBOT_PACKAGE_ACTUAL_CHECKSUM}"
   exit 9
fi


# Expected File Checksum
#REGSYNC_PACKAGE_EXPECTED_CHECKSUM=$(cat "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/checksum/${REGSYNC_CHECKSUM_FILENAME}" | jq -r ".metadata.component.version" | sed -E "s|sha256:([0-9a-zA-Z]+).*?$|\1|g")
REGSYNC_PACKAGE_EXPECTED_CHECKSUM=$(jq -r ".metadata.component.version" "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/checksum/${REGSYNC_CHECKSUM_FILENAME}" | sed -E "s|sha256:([0-9a-zA-Z]+).*?$|\1|g")

# Calculate Actual Checksum
REGSYNC_PACKAGE_ACTUAL_CHECKSUM=$(sha256sum "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGSYNC_PACKAGE_FILENAME}" | head -c 64)

# Check if checksum is correct
REGSYNC_PACKAGE_CHECK_CHECKSUM=$(echo "${REGSYNC_PACKAGE_EXPECTED_CHECKSUM} ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGSYNC_PACKAGE_FILENAME}" | sha256sum -c --status)

# If Checksum is invalid, exit
if [[ ${REGSYNC_PACKAGE_CHECK_CHECKSUM} -ne 0 ]]
then
   echo "Checksum of Package Regbot is Invalid: expected ${REGSYNC_PACKAGE_EXPECTED_CHECKSUM} for File ${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGSYNC_PACKAGE_FILENAME}, got ${REGSYNC_PACKAGE_ACTUAL_CHECKSUM}"
   exit 9
fi



# Copy Files from Cache Folder to Destination Folder
cp "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGCTL_PACKAGE_FILENAME}" "${REGCLIENT_PATH}/regctl"
cp "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGBOT_PACKAGE_FILENAME}" "${REGCLIENT_PATH}/regbot"
cp "${REGCLIENT_CACHE_PATH}/${REGCLIENT_VERSION}/${REGSYNC_PACKAGE_FILENAME}" "${REGCLIENT_PATH}/regsync"


# Make Binary File(s) executable
chmod +x ${REGCLIENT_PATH}/*
