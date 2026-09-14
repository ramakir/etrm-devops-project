pipeline {
    agent {
        label 'etrm-dev-agent'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
    }

    post {
        success {
            echo 'CI pipeline completed successfully.'
        }

        failure {
            echo 'CI pipeline failed. Check the stage logs for details.'
        }
    }
}
