pipeline {
    agent any

    stages {

        stage('Detect changed services') {
            steps {
                script {
                    // List changed files vs the previous commit, then keep the top-level folder of each
                    def changed = sh(
                        script: "git diff --name-only HEAD~1 HEAD | cut -d/ -f1 | sort -u",
                        returnStdout: true
                    ).trim()

                    echo "Changed folders:\n${changed}"
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