pipeline {
    agent any

    stages {

        stage('Detect changed services') {
            steps {
                script {
                    // Detection logic now lives in a shared script (modular, reusable)
                    def changed = sh(
                        script: "bash shared/ci/detect.sh",
                        returnStdout: true
                    ).trim()

                    echo "Services to build:\n${changed}"
                    env.CHANGED_SERVICES = changed
                }
            }
        }

        stage('CI (placeholder)') {
            steps {
                echo "Would run CI for:\n${env.CHANGED_SERVICES}"
            }
        }
    }
}