// Jenkinsfile
//
// Mock version of the "Jenkins Test Builds" flow from the reverse-demo
// diagram: Jenkins Job -> Jenkins Controller -> (GKE) Worker Pod, which
// builds the artifact and sends it through a security scan lane
// (Artifactory X-Ray + Snyk) in parallel with packaging.
//
// This is the job Unify RO will call via the "Run a Jenkins job" action
// (cloudbees-io/jenkins-run-job) in ngsm-release.yml — Unify does not
// replace this pipeline, it orchestrates it.

pipeline {
    agent any

    parameters {
        string(name: 'RELEASE_MANIFEST_PATH', defaultValue: 'manifest/release-manifest.yaml',
               description: 'Path to the release manifest defining components + image types')
    }

    environment {
        // Bridges the Jenkins *parameter* into a real shell environment
        // variable — sh steps below can't see params.* directly.
        RELEASE_MANIFEST_PATH = "${params.RELEASE_MANIFEST_PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Load Release Manifest') {
            steps {
                sh '''
                    echo "Loading release manifest from ${RELEASE_MANIFEST_PATH}"
                    cat "${RELEASE_MANIFEST_PATH}"
                '''
            }
        }

        stage('Build ISO (mock)') {
            steps {
                sh 'bash scripts/build-iso.sh "${RELEASE_MANIFEST_PATH}"'
            }
        }

        stage('Security Scan') {
            parallel {
                stage('Artifactory X-Ray Scan (mock)') {
                    steps {
                        sh 'echo "[xray] scanning build/ngsm-release.iso ... no critical findings"'
                    }
                }
                stage('Snyk Scan (mock)') {
                    steps {
                        sh 'echo "[snyk] scanning dependencies ... new-code gate passed"'
                    }
                }
            }
        }

        stage('Publish Artifact') {
            steps {
                sh '''
                    echo "Publishing build/ngsm-release.iso to mock Artifactory path"
                    echo "artifact_url=https://artifactory.example.internal/hpe-releases/ngsm/${BUILD_NUMBER}/ngsm-release.iso" > build/artifact.properties
                    cat build/artifact.properties
                '''
                archiveArtifacts artifacts: 'build/*', fingerprint: true
            }
        }
    }

    post {
        success {
            echo "Build ${BUILD_NUMBER} complete — ready for Unify RO to pick up for cluster install"
        }
    }
}
