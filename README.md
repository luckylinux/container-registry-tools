# Introduction
Tools for helping use Container Registry.

Includes:
- Skopeo
- RegClient (`regctl` , `regbot`, `regsync`)
- Crane (`crane` , `gcrane`, `krane`)

Note: the following individual Images are also available from the Official Tool Developers
- [regctl](ghcr.io/regclient/regctl)
- [regbot](ghcr.io/regclient/regbot)
- [regsync](ghcr.io/regclient/regsync)

# Motivation
The main Motivation for this Docker/Podman/Container Image was to be able to:
- Use the Custom `registries.conf` Configuration preferring Local Mirror on the Host
- Use the Default `registries.conf` Configuration using Stock Registries so that the Apps inside the Container can bypass the Local Mirror

Of course this also includes not having to install extra Tools on the Host :smiley:.

# Build
The Container can simply be built using:
```
./build.sh
```

Edit the Options to your liking.

# Usage
The Container runs an Infinite Loop that can handle `SIGTERM` correctly.
This means that the Container can be stopped normally and without significant Delays.

```
# Set containerconfigfolder to default configuration in GitHub Repository
#containersconfigfolder="./containers"

# Set containerconfigfolder to somewhere that fits you (more permanent)
containersconfigfolder="${HOME}/.config/skopeo"

# Set a name for the Container
container="container-registry-tools"

# Run the Container
podman run -d --replace --rm --name=${name} --env-file "./.env" -v "${containersconfigfolder}:/etc/containers" "localhost/docker-registry-tools:latest"

```

## Interactive Command Execution
Enter the Container Shell (BASH):
```
podman exec -it "${name}" /bin/bash
```

Then perform the required Operation, as if you had those commands on the Host:
```
skopeo sync --scoped --src "docker" --dest "docker" --all "ghcr.io/home-assistant/home-assistant:stable" "${LOCAL_MIRROR}"
```

## Non-Interactive Command Execution
In this case, Docker/BASH Variable Expansion and single/double Quotes become a bit more Tricky.

## Using Quote Escaping
```
# Execute Command
podman exec "${name}" bash -c "skopeo sync --scoped --src docker --dest docker --all \"ghcr.io/home-assistant/home-assistant:stable\" \"${LOCAL_MIRROR}\""
```


## Using Variable Expansion
```
# Build Commands Args for use with Variable Expansion
eargs=()
eargs+=("--scoped")
eargs+=("--src")
eargs+=("docker")
eargs+=("--dest")
eargs+=("docker")
eargs+=("--all")
eargs+=("ghcr.io/home-assistant/home-assistant:stable")
eargs+=("${LOCAL_MIRROR}")

# Execute Command
podman exec "${name}" bash -c "skopeo sync ${eargs[*]}"
```
