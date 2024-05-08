#!/bin/bash

# Exit on Error
set -e

# Enable Verbose Output
# set -x

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


# Supercronic Package Filename
SUPERCRONIC_PACKAGE_FILENAME="supercronic-linux-${ARCHITECTURE}"

# Supercronic Checksum Filename
# Unfortunately a separate file is not available - SHA256 Hash is Hardcoded into the Release Page
# SUPERCRONIC_CHECKSUM_FILENAME="checksums.txt"

# Supercronic Package Download Link
SUPERCRONIC_PACKAGE_URL="${SUPERCRONIC_BASE_URL}/${SUPERCRONIC_PACKAGE_FILENAME}"

# Supercronic Checksum Download Link
# Unfortunately a separate file is not available - SHA256 Hash is Hardcoded into the Release Page
# SUPERCRONIC_CHECKSUM_URL="${SUPERCRONIC_BASE_URL}/${SUPERCRONIC_CHECKSUM_FILENAME}"

# Echo
echo "Package URL Set to: ${SUPERCRONIC_PACKAGE_URL}"

# Unfortunately a separate file is not available - SHA256 Hash is Hardcoded into the Release Page
# echo "Checksum URL Set to: ${SUPERCRONIC_CHECKSUM_URL}"

# Create Directory for Supercronic Executables (if it doesn't exist yet)
mkdir -p "${SUPERCRONIC_PATH}"

# Create a ${SUPERCRONIC_VERSION} subdirectory within ${SUPERCRONIC_CACHE_PATH}
mkdir -p "${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}"

# By default must download
SUPERCRONIC_PACKAGE_DOWNLOAD=1
SUPERCRONIC_CHECKSUM_DOWNLOAD=1



# Check if Checksum File exists in Cache
# Unfortunately a separate file is not available - SHA256 Hash is Hardcoded into the Release Page
#if [[ -f "${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}/${SUPERCRONIC_CHECKSUM_FILENAME}" ]]
#then
#    # Checksum File exists
#    SUPERCRONIC_CHECKSUM_DOWNLOAD=0
#else
#    # Download Checksum File
#    echo "Downloading Checksum File for Supercronic from ${SUPERCRONIC_CHECKSUM_URL}"
#    curl -sS -L --output-dir "${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}" -o "${SUPERCRONIC_CHECKSUM_FILENAME}" --create-dirs "${SUPERCRONIC_CHECKSUM_URL}"
#fi




# Check if Package File exists in Cache
if [[ -f "${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}/${SUPERCRONIC_PACKAGE_FILENAME}" ]]
then
   # Package File exists
   SUPERCRONIC_PACKAGE_DOWNLOAD=0
fi

# Check if need to re-download Package
if [[ ${SUPERCRONIC_PACKAGE_DOWNLOAD} -ne 0 ]]
then
   # Download Package File
   echo "Downloading Package for Supercronic from ${SUPERCRONIC_PACKAGE_URL}"
   curl -sS -L --output-dir "${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}" -o "${SUPERCRONIC_PACKAGE_FILENAME}" --create-dirs "${SUPERCRONIC_PACKAGE_URL}"
else
   # Echo
   echo "Using Cache for Supercronic from ${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}/${SUPERCRONIC_PACKAGE_FILENAME}"
fi




# Expected File Checksum
# Unfortunately a separate file is not available - SHA256 Hash is Hardcoded into the Release Page
#SUPERCRONIC_PACKAGE_EXPECTED_CHECKSUM=$(cat "${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}/${SUPERCRONIC_CHECKSUM_FILENAME}" | grep "${SUPERCRONIC_PACKAGE_FILENAME}" | head -c 64 )

# Calculate Actual Checksum
SUPERCRONIC_PACKAGE_ACTUAL_CHECKSUM=$(sha256sum "${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}/${SUPERCRONIC_PACKAGE_FILENAME}" | head -c 64)

# Check if checksum is correct
# Unfortunately a separate file is not available - SHA256 Hash is Hardcoded into the Release Page
#SUPERCRONIC_PACKAGE_CHECK_CHECKSUM=$(echo "${SUPERCRONIC_PACKAGE_EXPECTED_CHECKSUM} ${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}/${SUPERCRONIC_PACKAGE_FILENAME}" | sha256sum -c --status)

# If Checksum is invalid, exit
# Unfortunately a separate file is not available - SHA256 Hash is Hardcoded into the Release Page
#if [[ ${SUPERCRONIC_PACKAGE_CHECK_CHECKSUM} -ne 0 ]]
#then
#   echo "Checksum of Package Supercronic is Invalid: expected ${SUPERCRONIC_PACKAGE_EXPECTED_CHECKSUM} for File ${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}/${SUPERCRONIC_PACKAGE_FILENAME}, got ${SUPERCRONIC_PACKAGE_ACTUAL_CHECKSUM}"
#   exit 9
#fi


# Copy Files from Cache Folder to Destination Folder
cp "${SUPERCRONIC_CACHE_PATH}/${SUPERCRONIC_VERSION}/${SUPERCRONIC_PACKAGE_FILENAME}" "${SUPERCRONIC_PATH}/supercronic"


# Make Binary File(s) executable
chmod +x ${SUPERCRONIC_PATH}/*

# Also create a Configuration Folder in /etc/supercronic
mkdir -p /etc/supercronic
