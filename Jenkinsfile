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
                sh 'TMPDIR=/var/lib/trivy-tmp trivy image --scanners vuln --severity HIGH,CRITICAL --exit-code 1 --no-progress 952121199249.dkr.ecr.ap-south-1.amazonaws.com/etrm/trade-service:ci-${BUILD_NUMBER}'
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region ap-south-1 |
                    docker login --username AWS --password-stdin 952121199249.dkr.ecr.ap-south-1.amazonaws.com

                    docker push 952121199249.dkr.ecr.ap-south-1.amazonaws.com/etrm/trade-service:ci-${BUILD_NUMBER}
                '''
            }
        }

        stage('Update GitOps Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-https-push',
                    usernameVariable: 'GIT_USERNAME',
                    passwordVariable: 'GIT_TOKEN'
                )]) {
                    sh '''
                        git config user.name "jenkins"
                        git config user.email "jenkins@etrm-devops.local"

                        sed -i "s#\\(image: 952121199249.dkr.ecr.ap-south-1.amazonaws.com/etrm/trade-service:\\).*#\\1ci-${BUILD_NUMBER}#" kubernetes/deployment.yaml

                        git add kubernetes/deployment.yaml
                        git commit -m "Update trade-service image to ci-${BUILD_NUMBER}"

                        git push https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/ramakir/etrm-devops-project.git HEAD:main
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs for details.'
        }
    }
}