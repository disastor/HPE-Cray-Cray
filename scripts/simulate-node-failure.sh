#!/usr/bin/env bash
# simulate-node-failure.sh — deliberately fails on the last node.
#
# Dedicated failure scenario for the demo: two nodes succeed, the third
# fails, so there's a real non-zero exit for the workflow to react to.
# Kept separate from install-via-login-node.sh so the main release demo
# stays deterministic and this can be run repeatedly on its own.
#
# Writes an explicit "result" output file into $CLOUDBEES_OUTPUTS
# (confirmed to be a directory, not an appendable file, in this
# docker://bash:5.2 step context) since steps.<id>.outcome is not
# available on steps that use a `uses:` container action.

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
echo "CLOUDBEES_OUTPUTS is: ${CLOUDBEES_OUTPUTS:-UNSET}"
if [ -n "${CLOUDBEES_OUTPUTS:-}" ]; then
  ls -la "$CLOUDBEES_OUTPUTS" 2>&1 || echo "(could not list CLOUDBEES_OUTPUTS)"
  echo -n "failure" > "$CLOUDBEES_OUTPUTS/result"
  echo "Wrote result=failure to $CLOUDBEES_OUTPUTS/result"
fi
# This step must exit 0 - outputs are only captured when the step
# itself succeeds. The "Reflect the real outcome" step later in the
# workflow is what actually fails the run, once everything conditional
# on this result has already had a chance to execute.
exit 0
