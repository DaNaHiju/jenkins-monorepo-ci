pipeline {
    agent any

    stages {

        stage('Detect changed services') {
            steps {
                script {
                    def changed = sh(
                        script: "bash shared/ci/detect.sh",
                        returnStdout: true
                    ).trim()

                    echo "Services to build:\n${changed}"
                    env.CHANGED_SERVICES = changed
                }
            }
        }

        stage('Verify Node agent') {
            agent {
                docker {
                    image 'node:20-alpine'
                    reuseNode true
                }
            }
            steps {
                sh 'node --version'
                sh 'npm --version'
            }}
        stage('Verify Python agent') {
            agent {
                docker {
                    image 'python:3.12-slim'
                    reuseNode true
                }
            }
            steps {
                sh 'python --version'
                sh 'pip --version'
            }
        }
    }
}