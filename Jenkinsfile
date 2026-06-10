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
        stage('Lint') {
            parallel {
                stage('Lint user-service') {
                    agent {
                        docker {
                            image 'node:20-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('user-service') {
                            sh 'npm install'
                            sh 'npm run lint'
                        }
                    }
                }
                stage('Lint transaction-service') {
                    agent {
                        docker {
                            image 'python:3.12-slim'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('transaction-service') {
                            sh 'pip install -r requirements.txt'
                            sh 'flake8 .'
                        }
                    }
                }
            }
        }
    }
}