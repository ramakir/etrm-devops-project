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

        stage('Test') {
            steps {
                dir('application/trade-service') {
                    sh 'mvn test'
                }
            }
        }

        stage('Package') {
            steps {
                dir('application/trade-service') {
                    sh 'mvn package -DskipTests'
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('application/trade-service') {
                    sh 'docker build -t 952121199249.dkr.ecr.ap-south-1.amazonaws.com/etrm/trade-service:ci-${BUILD_NUMBER} .'
                }
            }
        }

        stage('Security Scan') {
            steps {
                sh 'trivy image --scanners vuln --skip-java-db-update --severity HIGH,CRITICAL --exit-code 1 --no-progress 952121199249.dkr.ecr.ap-south-1.amazonaws.com/etrm/trade-service:ci-${BUILD_NUMBER}'
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


