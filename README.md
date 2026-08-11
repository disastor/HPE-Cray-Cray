# NGSM Release Demo — Unify RO for HPE (Thursday walkthrough)

Mock repo for the HPE demo. Recreates their actual architecture (per the
"Jenkins Test Builds" diagram and TriggerDB v2 screenshots) at small scale
so the flow is real and runnable, not a generic example.

## What's in here

| File | Stands in for |
|---|---|
| `Jenkinsfile` | Their existing Jenkins Job → Controller → Worker Pod build path, incl. the Artifactory X-Ray / Snyk scan lane |
| `manifest/release-manifest.yaml` | TriggerDB's Products Management + Image Types combinatorics (product bundle × arch × distro) |
| `scripts/build-iso.sh` | Mock ISO packaging |
| `scripts/install-via-login-node.sh` | The login-node gateway → shard → aggregate pattern from their diagram |
| `.cloudbees/workflows/ngsm-release.yml` | **The Unify RO workflow** — this is what to show live |

## Setup before Thursday

1. Push this repo to GitHub (or your demo org's SCM) and connect it as a component in the Unify demo org.
2. Set `JENKINS_URL`, `JENKINS_USERNAME`, `JENKINS_TOKEN` as workflow vars/secrets, pointing at a Jenkins instance with a job named `ngsm-iso-build` running this repo's `Jenkinsfile`. (A CloudBees CI trial instance works fine — this doesn't need to be HPE's actual Jenkins.)
3. Confirm the `hpc-test-cluster` environment exists in Unify (or rename it to whatever environment you've set up in the demo org).
4. Workflow YAML has been validated against Unify's schema (`workflow_validate` — passed clean as of this build).

## Walking through it live — maps to the demo plan (Section 3)

1. **Open with their diagram.** Show the workflow graph in Unify next to their own "Jenkins Test Builds" diagram — same shape: build → gateway → shard/aggregate → results.
2. **`build-iso` job.** Trigger the workflow manually (`workflow_dispatch`). Point out this calls their *existing* Jenkins job as-is — no rewritten pipeline.
3. **`release-approval` job.** Show the approval prompt. Say explicitly that this job is optional — remove it and the workflow still runs end-to-end. This is the RBAC/audit-trail story without leading with security.
4. **`deploy-test-cluster` job.** Watch the simulated login-node/shard/aggregate output stream live — this is the literal "one-click button and see the logs" bar Jennifer set.
5. **Release manifest.** Open `release-manifest.yaml` next to TriggerDB's Products Management screen — same product names (NGSM-Base, HPCM_ADMIN, CPE, PBS), same third-party flag, same arch/distro combinations.
6. **Registered artifacts.** Show the build artifact and deployed artifact both tracked in Unify, tied to the same release — this is the CI→CD traceability answer to "ticket to download-site timeline."
7. **`notify` job.** Slack message — same shape as their existing test-status ping, now coming from a governed release instead of a custom script.

## What NOT to say live

- Don't frame this as "replacing Ansible" — the `deploy-test-cluster` job is deliberately a stand-in for their SSH/gateway pattern, not a claim that Ansible is gone.
- Don't imply this is running against their real HPC cluster — say plainly it's simulated, and that the production version would target the real login node via SSH or a self-hosted runner on that side of the network boundary.
- Don't lean on the security-scan lane as the main pitch — per the plan, usability and maintainability are the levers that move this deal, not compliance.
