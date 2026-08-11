#!/usr/bin/env bash
# build-iso.sh — mock ISO packaging step.
#
# Stands in for HPE's real ISO packaging process: pulls the components
# listed in the release manifest and bundles them into a single
# installable image, the same way each of their ~50-100 sub-products
# per team get packaged into one deployable unit.

set -euo pipefail

MANIFEST_PATH="${1:-manifest/release-manifest.yaml}"
mkdir -p build

echo "Building ISO from manifest: ${MANIFEST_PATH}"
echo "Components bundled:"
grep -A1 "product:" "${MANIFEST_PATH}" | grep -E "product:|version:" | paste - - | sed 's/^/  - /'

# Produce a placeholder artifact + checksum so downstream steps
# (publish, register-build-artifact) have something real to reference.
echo "This is a mock ISO for demo purposes — built $(date -u +%Y-%m-%dT%H:%M:%SZ)" > build/ngsm-release.iso
sha256sum build/ngsm-release.iso > build/ngsm-release.iso.sha256

echo "Build complete: build/ngsm-release.iso"
