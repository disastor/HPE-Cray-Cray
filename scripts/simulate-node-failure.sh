#!/usr/bin/env bash

set -euo pipefail

ARTIFACT_URL="${1:-unknown-artifact}"

echo "== Pre-flight: system discovery / heartbeat check =="
sleep 1
echo "  reservation check: system is checked out to this run — proceeding"
echo

echo "== Dispatching install via Login Node (gateway) =="
echo "Artifact: ${ARTIFACT_URL}"
echo

echo "  -> shard dispatched to Cluster Node A"
sleep 1
echo "  <- aggregate received from Cluster Node A: install OK"

echo "  -> shard dispatched to Cluster Node B"
sleep 1
echo "  <- aggregate received from Cluster Node B: install OK"

echo "  -> shard dispatched to Cluster Node N"
sleep 1
echo "  <- aggregate received from Cluster Node N: ERROR - package dependency mismatch after heartbeat check"

echo
echo "Install failed on Cluster Node N. 2/3 nodes succeeded."

if [ -n "${CLOUDBEES_OUTPUTS:-}" ]; then
  echo "result=failure" >> "$CLOUDBEES_OUTPUTS"
fi

exit 1
