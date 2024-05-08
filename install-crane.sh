#!/bin/bash

# Exit on Error
set -e

# Enable Verbose Output
# set -x

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Tag
CRANE_TAG=${2-"latest"}

# Install Path
CRANE_PATH="/opt/crane"

# Cache Path
CRANE_CACHE_PATH="/var/lib/installer/crane"

# Repository
CRANE_REPOSITORY="google/go-containerregistry"

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
   # Define Base URL
   CRANE_BASE_URL="https://github.com/${CRANE_REPOSITORY}/releases/latest/download"

   # Retrieve what Version the "latest" tag Corresponds to
   CRANE_VERSION=$(curl -H "Accept: application/vnd.github.v3+json" -sS  "https://api.github.com/repos/${CRANE_REPOSITORY}/tags" | jq -r '.[0].name')
else
   # Define Base URL
   CRANE_BASE_URL="https://github.com/${CRANE_REPOSITORY}/releases/download/${CRANE_TAG}"

   # Version is the same as the Tag
   CRANE_VERSION=${CRANE_TAG}
fi

# Echo
echo "Base URL Set to: ${CRANE_BASE_URL}"


# Crane Package Filename
CRANE_PACKAGE_FILENAME="go-containerregistry_Linux_${ARCHITECTURE}.tar.gz"

# Crane Checksum Filename
CRANE_CHECKSUM_FILENAME="checksums.txt"

# Crane Package Download Link
CRANE_PACKAGE_URL="${CRANE_BASE_URL}/${CRANE_PACKAGE_FILENAME}"

# Crane Checksum Download Link
CRANE_CHECKSUM_URL="${CRANE_BASE_URL}/${CRANE_CHECKSUM_FILENAME}"

# Echo
echo "Package URL Set to: ${CRANE_PACKAGE_URL}"
echo "Checksum URL Set to: ${CRANE_CHECKSUM_URL}"

# Create Directory for Crane Executables (if it doesn't exist yet)
mkdir -p "${CRANE_PATH}"

# Create a ${CRANE_VERSION} subdirectory within ${CRANE_CACHE_PATH}
mkdir -p "${CRANE_CACHE_PATH}/${CRANE_VERSION}"

# By default must download
CRANE_PACKAGE_DOWNLOAD=1
CRANE_CHECKSUM_DOWNLOAD=1




# Check if Checksum File exists in Cache
if [[ -f "${CRANE_CACHE_PATH}/${CRANE_VERSION}/${CRANE_CHECKSUM_FILENAME}" ]]
then
    # Checksum File exists
    CRANE_CHECKSUM_DOWNLOAD=0
else
    # Download Checksum File
    echo "Downloading Checksum File for Crane from ${CRANE_CHECKSUM_URL}"
    curl -sS -L --output-dir "${CRANE_CACHE_PATH}/${CRANE_VERSION}" -o "${CRANE_CHECKSUM_FILENAME}" --create-dirs "${CRANE_CHECKSUM_URL}"
fi




# Check if Package File exists in Cache
if [[ -f "${CRANE_CACHE_PATH}/${CRANE_VERSION}/${CRANE_PACKAGE_FILENAME}" ]]
then
   # Package File exists
   CRANE_PACKAGE_DOWNLOAD=0
fi

# Check if need to re-download Package
if [[ ${CRANE_PACKAGE_DOWNLOAD} -ne 0 ]]
then
   # Download Package File
   echo "Downloading Package for Crane from ${CRANE_PACKAGE_URL}"
   curl -sS -L --output-dir "${CRANE_CACHE_PATH}/${CRANE_VERSION}" -o "${CRANE_PACKAGE_FILENAME}" --create-dirs "${CRANE_PACKAGE_URL}"
else
   # Echo
   echo "Using Cache for Crane from ${CRANE_CACHE_PATH}/${CRANE_VERSION}/${CRANE_PACKAGE_FILENAME}"
fi




# Expected File Checksum
CRANE_PACKAGE_EXPECTED_CHECKSUM=$(cat "${CRANE_CACHE_PATH}/${CRANE_VERSION}/${CRANE_CHECKSUM_FILENAME}" | grep "${CRANE_PACKAGE_FILENAME}" | head -c 64 )

# Calculate Actual Checksum
CRANE_PACKAGE_ACTUAL_CHECKSUM=$(sha256sum "${CRANE_CACHE_PATH}/${CRANE_VERSION}/${CRANE_PACKAGE_FILENAME}" | head -c 64)

# Check if checksum is correct
CRANE_PACKAGE_CHECK_CHECKSUM=$(echo "${CRANE_PACKAGE_EXPECTED_CHECKSUM} ${CRANE_CACHE_PATH}/${CRANE_VERSION}/${CRANE_PACKAGE_FILENAME}" | sha256sum -c --status)

# If Checksum is invalid, exit
if [[ ${CRANE_PACKAGE_CHECK_CHECKSUM} -ne 0 ]]
then
   echo "Checksum of Package Crane is Invalid: expected ${CRANE_PACKAGE_EXPECTED_CHECKSUM} for File ${CRANE_CACHE_PATH}/${CRANE_VERSION}/${CRANE_PACKAGE_FILENAME}, got ${CRANE_PACKAGE_ACTUAL_CHECKSUM}"
   exit 9
fi

# Decompress the Archive
tar xf "${CRANE_CACHE_PATH}/${CRANE_VERSION}/${CRANE_PACKAGE_FILENAME}" -C ${CRANE_PATH}

# Remove the temporary Archive
# Disabled since we want to take advantage of Docker Buildx/Podman Buildah Cache
# rm -f /tmp/crane.tar.gz

# Make Binary File(s) executable
chmod +x ${CRANE_PATH}/*
