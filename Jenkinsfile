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
                    image 'node:20'
                    args '-v jenkins_home:/var/jenkins_home'
                    reuseNode true
                }
            }
            steps {
                sh 'node --version'
                sh 'npm --version'
            }
        }
    }
}