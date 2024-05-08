#!/bin/bash

# Exit on Error
set -e

# Enable Verbose Output
# set -x

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Tag
SKOPEO_TAG=${2-"latest"}

# Install Path
SKOPEO_PATH="/opt/skopeo"

# Cache Path
SKOPEO_CACHE_PATH="/var/lib/installer/skopeo"

# Repository
SKOPEO_REPOSITORY="lework/skopeo-binary"

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
   # Define Base URL
   SKOPEO_BASE_URL="https://github.com/${SKOPEO_REPOSITORY}/releases/latest/download"

   # Retrieve what Version the "latest" tag Corresponds to
   SKOPEO_VERSION=$(curl -H "Accept: application/vnd.github.v3+json" -sS  "https://api.github.com/repos/${SKOPEO_REPOSITORY}/tags" | jq -r '.[0].name')
else
   # Define Base URL
   SKOPEO_BASE_URL="https://github.com/${SKOPEO_REPOSITORY}/releases/download/${SKOPEO_TAG}"

   # Version is the same as the Tag
   SKOPEO_VERSION=${SKOPEO_TAG}
fi

# Echo
echo "Base URL Set to: ${SKOPEO_BASE_URL}"



# Skopeo Package Filename
SKOPEO_PACKAGE_FILENAME="skopeo-linux-${ARCHITECTURE}"

# Skopeo Checksum Filename
SKOPEO_CHECKSUM_FILENAME="skopeo-linux-${ARCHITECTURE}.sha256"

# Skopeo Package Download Link
SKOPEO_PACKAGE_URL="${SKOPEO_BASE_URL}/${SKOPEO_PACKAGE_FILENAME}"

# Skopeo Checksum Download Link
SKOPEO_CHECKSUM_URL="${SKOPEO_BASE_URL}/${SKOPEO_CHECKSUM_FILENAME}"



# Echo
echo "Package URL Set to: ${SKOPEO_PACKAGE_URL}"
echo "Checksum URL Set to: ${SKOPEO_CHECKSUM_URL}"

# Create Directory for Skopeo Executables (if it doesn't exist yet)
mkdir -p "${SKOPEO_PATH}"

# Create a ${SKOPEO_VERSION} subdirectory within ${SKOPEO_CACHE_PATH}
mkdir -p "${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}"

# By default must download
SKOPEO_PACKAGE_DOWNLOAD=1
SKOPEO_CHECKSUM_DOWNLOAD=1



# Check if Checksum File exists in Cache
if [[ -f "${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}/${SKOPEO_CHECKSUM_FILENAME}" ]]
then
    # Checksum File exists
    SKOPEO_CHECKSUM_DOWNLOAD=0
else
    # Download Checksum File
    echo "Downloading Checksum File for Skopeo from ${SKOPEO_CHECKSUM_URL}"
    curl -sS -L --output-dir "${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}" -o "${SKOPEO_CHECKSUM_FILENAME}" --create-dirs "${SKOPEO_CHECKSUM_URL}"
fi




# Check if Package File exists in Cache
if [[ -f "${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}/${SKOPEO_PACKAGE_FILENAME}" ]]
then
   # Package File exists
   SKOPEO_PACKAGE_DOWNLOAD=0
fi

# Check if need to re-download Package
if [[ ${SKOPEO_PACKAGE_DOWNLOAD} -ne 0 ]]
then
   # Download Package File
   echo "Downloading Package for Skopeo from ${SKOPEO_PACKAGE_URL}"
   curl -sS -L --output-dir "${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}" -o "${SKOPEO_PACKAGE_FILENAME}" --create-dirs "${SKOPEO_PACKAGE_URL}"
else
   # Echo
   echo "Using Cache for Skopeo from ${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}/${SKOPEO_PACKAGE_FILENAME}"
fi




# Expected File Checksum
SKOPEO_PACKAGE_EXPECTED_CHECKSUM=$(cat "${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}/${SKOPEO_CHECKSUM_FILENAME}" | grep "${SKOPEO_PACKAGE_FILENAME}" | head -c 64 )

# Calculate Actual Checksum
SKOPEO_PACKAGE_ACTUAL_CHECKSUM=$(sha256sum "${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}/${SKOPEO_PACKAGE_FILENAME}" | head -c 64)

# Check if checksum is correct
SKOPEO_PACKAGE_CHECK_CHECKSUM=$(echo "${SKOPEO_PACKAGE_EXPECTED_CHECKSUM} ${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}/${SKOPEO_PACKAGE_FILENAME}" | sha256sum -c --status)

# If Checksum is invalid, exit
if [[ ${SKOPEO_PACKAGE_CHECK_CHECKSUM} -ne 0 ]]
then
   echo "Checksum of Package Skopeo is Invalid: expected ${SKOPEO_PACKAGE_EXPECTED_CHECKSUM} for File ${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}/${SKOPEO_PACKAGE_FILENAME}, got ${SKOPEO_PACKAGE_ACTUAL_CHECKSUM}"
   exit 9
fi


# Copy Files from Cache Folder to Destination Folder
cp "${SKOPEO_CACHE_PATH}/${SKOPEO_VERSION}/${SKOPEO_PACKAGE_FILENAME}" "${SKOPEO_PATH}/skopeo"


# Make Binary File(s) executable
chmod +x ${SKOPEO_PATH}/*
