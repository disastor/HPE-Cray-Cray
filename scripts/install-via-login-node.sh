#!/usr/bin/env bash
# install-via-login-node.sh — mock deployment step.
#
# Simulates HPE's real deployment path from the "Jenkins Test Builds"
# diagram: the only reachable node is the Login Node (a gateway); from
# there, work is sharded out to individually named cluster nodes and
# results are aggregated back. In production this step would run via
# an SSH-based deployer action (or a self-hosted runner) reaching the
# real login node — for this demo it simulates that exchange so the
# flow is visible end-to-end without needing live HPC infrastructure.
#
# It also simulates the pre-flight "heartbeat" / system-discovery check
# HPE runs before every install to catch state drift.

set -euo pipefail

ARTIFACT_URL="${1:-unknown-artifact}"
NODES=("Cluster Node A" "Cluster Node B" "Cluster Node N")

echo "== Pre-flight: system discovery / heartbeat check =="
echo "Verifying current cluster state before install (assume drift until proven otherwise)..."
sleep 1
echo "  system management nodes: 2/2 online"
echo "  fabric manager nodes: OK"
echo "  reservation check: system is checked out to this run — proceeding"
echo

echo "== Dispatching install via Login Node (gateway) =="
echo "Artifact: ${ARTIFACT_URL}"
echo

RESULTS=()
for NODE in "${NODES[@]}"; do
    echo "  -> shard dispatched to ${NODE}"
    sleep 1
    echo "  <- aggregate received from ${NODE}: install OK"
    RESULTS+=("{\"node\":\"${NODE}\",\"status\":\"success\"}")
done

echo
echo "== POST results to REST API Service =="
JSON_RESULT=$(printf '%s,' "${RESULTS[@]}")
JSON_RESULT="[${JSON_RESULT%,}]"
echo "Payload: ${JSON_RESULT}"
echo "(In production: written to ELK/OpenTelemetry, test status pushed to Slack)"

echo
echo "Install complete across ${#NODES[@]} nodes."
