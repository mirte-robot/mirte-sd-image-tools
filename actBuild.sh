#!/bin/bash
rm -rf artifacts_temp || true
mkdir artifacts_temp
act -j build_installer --container-options="-v /dev:/dev -v /proc:/proc --privileged" --artifact-server-path artifacts_temp
mkdir artifacts || true
cp -r artifacts_temp/* ./artifacts
# somehow the files get an extra __ at the end
find ./artifacts -name "*.gz__" -exec sh -c 'mv "$1" "${1%.gz__}.gz"' _ {} \;
find ./artifacts -name "*.gz" -exec sh -c 'gunzip "$1"' _ {} \;
