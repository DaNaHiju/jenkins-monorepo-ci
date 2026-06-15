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
                            args '--user root'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('transaction-service') {
                            sh 'pip install --break-system-packages -r requirements.txt'
                            sh 'flake8 .'
                        }
                    }
                }
            }
        }
        stage('Test') {
            parallel {
                stage('Test user-service') {
                    agent {
                        docker {
                            image 'node:20-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('user-service') {
                            sh 'npm install'
                            sh 'npm test'
                        }
                    }
                    post {
                        always {
                            junit 'user-service/reports/junit.xml'
                        }
                    }
                }
                stage('Test transaction-service') {
                    agent {
                        docker {
                            image 'python:3.12-slim'
                            args '--user root'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('transaction-service') {
                            sh 'pip install --break-system-packages -r requirements.txt'
                            sh 'pytest --junitxml=reports/junit.xml'
                        }
                    }
                    post {
                        always {
                            junit 'transaction-service/reports/junit.xml'
                        }
                    }
                }
            }
        }
        stage('Scan') {
            parallel {
                stage('Scan user-service') {
                    agent {
                        docker {
                            image 'node:20-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('user-service') {
                            sh 'npm audit --audit-level=high'
                        }
                    }
                }
                stage('Scan transaction-service') {
                    agent {
                        docker {
                            image 'python:3.12-slim'
                            args '--user root'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('transaction-service') {
                            sh 'pip install --break-system-packages pip-audit'
                            sh 'pip-audit -r requirements.txt'
                        }
                    }
                }
            }
        }
    }
}
