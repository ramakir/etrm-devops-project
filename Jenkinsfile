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
                        set +x

                        rm -rf etrm-gitops

                        export GIT_ASKPASS="$WORKSPACE/.git-askpass.sh"

                        cat > "$GIT_ASKPASS" <<'EOF'
#!/bin/sh
case "$1" in
    *Username*) printf '%s\\n' "$GIT_USERNAME" ;;
    *Password*) printf '%s\\n' "$GIT_TOKEN" ;;
esac
EOF

                        chmod 700 "$GIT_ASKPASS"

                        GIT_TERMINAL_PROMPT=0 git clone \
                            https://github.com/ramakir/etrm-gitops.git \
                            etrm-gitops

                        cd etrm-gitops

                        git config user.name "jenkins"
                        git config user.email "jenkins@etrm-devops.local"

                        sed -i "s#\\(image: 952121199249.dkr.ecr.ap-south-1.amazonaws.com/etrm/trade-service:\\).*#\\1ci-${BUILD_NUMBER}#" \
                            environments/dev/deployment.yaml

                        git add environments/dev/deployment.yaml

                        git commit -m "Update trade-service image to ci-${BUILD_NUMBER}"

                        GIT_TERMINAL_PROMPT=0 git push origin HEAD:main

                        cd ..

                        rm -rf etrm-gitops
                        rm -f "$GIT_ASKPASS"
                        unset GIT_ASKPASS
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