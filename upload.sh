#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing ${scriptpath}/${relativepath}); fi

# Load Configuration
libpath=$(readlink --canonicalize-missing "${toolpath}/includes")
source ${libpath}/functions.sh


# This is a "Hack" to allow compose.yml to pick up the Latest Image

# Image(s) Name(s)
images=${1-""}
if [[ -z "$images" ]]
then
    read -p "Enter the desired Image Name & Tag (e.g. mycontainer:mytag-latest) to Push to Local Registry (multiple items can be separated by commas): " images
fi

# Optional argument
engine=${2-"podman"}



# Check if Engine Exists
engine_exists "${engine}"
if [[ $? -ne 0 ]]
then
    # Error
    echo "[CRITICAL] Neither Podman nor Docker could be found and/or the specified Engine <$engine> was not valid."
    echo "ABORTING !"
    exit 9
fi


##################################################################################
# Also add entry in the main Regitries Configuration pointing to localhost:5000  #
# e.g. ~/.config/containers/registries.conf                                      #
#  unqualified-search-registries = ["localhost:5000", ...]                       #
##################################################################################

# Automatic Configuration is currently NOT working !!!
#sed -Ei "|^#?\s*?unqualified-search-registries\s*?=\s*?\[\"localhost:5000\"|!s|(.*)|unqualified-search-registries\s*?=\s*?\[\"localhost:5000\" , \1|g" "~/.config/containers/registries.conf"
#sed -Ei '/^##Input/! s/foo/bar/g' myfile

# Create a file /etc/containers/registries.conf.d/local-development.conf
mkdir -p ~/.config/containers/registries.conf.d/
cat > ~/.config/containers/registries.conf.d/local-development.conf <<EOF
[[registry]]
prefix = "localhost:5000"
location = "localhost:5000"
insecure = true
EOF

# Run a Local Registry WITHOUT Persistent Data Storage
run_local_registry "${engine}"

# Split Images Variable to support Multiple Images
IFS=','; imagesArray=($images); unset IFS;

# Iterate over image
for image in "${imagesArray[@]}"
do
   # Echo
   echo "Tag image <${image}> and pushing it to Local Registry <localhost:5000/local/${image}>"

   # Tag the Image
   ${engine} tag $image localhost:5000/local/$image

   # Push the locally built Image to the Local Registry
   # With Debugging
   #${engine} push --log-level debug --tls-verify=false localhost:5000/local/$image

   # Without Debugging
   ${engine} push --tls-verify=false localhost:5000/local/$image
done


# Edit docker-compose file to use localhost:5000/local/$image
# ...
