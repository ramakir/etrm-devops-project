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
        
        stage('Release Validation') {
            steps {
                sh '''
                    set -e
            
                    echo "Configuring EKS access..."

    		    aws eks update-kubeconfig \
        		--region ap-south-1 \
        		--name etrm-dev-eks

    		    echo "Verifying EKS access..."

                    kubectl get namespace etrm

                    EXPECTED_IMAGE="952121199249.dkr.ecr.ap-south-1.amazonaws.com/etrm/trade-service:ci-${BUILD_NUMBER}"

                    echo "Waiting for Kubernetes rollout..."

                    kubectl rollout status deployment/trade-service \
                        -n etrm \
                        --timeout=180s

                    echo "Checking deployed image..."

                    ACTUAL_IMAGE=$(kubectl get deployment trade-service \
                        -n etrm \
                        -o jsonpath='{.spec.template.spec.containers[0].image}')

                    echo "Expected image: ${EXPECTED_IMAGE}"
                    echo "Actual image:   ${ACTUAL_IMAGE}"

                    if [ "${ACTUAL_IMAGE}" != "${EXPECTED_IMAGE}" ]; then
                        echo "ERROR: Deployment image does not match expected build."
                        exit 1
                    fi

                    echo "Checking replica readiness..."

                    DESIRED=$(kubectl get deployment trade-service \
                    	-n etrm \
                    	-o jsonpath='{.spec.replicas}')

                    AVAILABLE=$(kubectl get deployment trade-service \
                        -n etrm \
                        -o jsonpath='{.status.availableReplicas}')

                    READY=$(kubectl get deployment trade-service \
                        -n etrm \
                        -o jsonpath='{.status.readyReplicas}')

                    UPDATED=$(kubectl get deployment trade-service \
                        -n etrm \
                        -o jsonpath='{.status.updatedReplicas}')

                    echo "Desired replicas:   ${DESIRED}"
                    echo "Available replicas: ${AVAILABLE}"
                    echo "Ready replicas:     ${READY}"
                    echo "Updated replicas:   ${UPDATED}"

                    if [ "${AVAILABLE}" != "${DESIRED}" ] || \
                       [ "${READY}" != "${DESIRED}" ] || \
                       [ "${UPDATED}" != "${DESIRED}" ]; then
                        echo "ERROR: Deployment replica validation failed."
                        exit 1
                    fi

                    echo "Checking actual pod images..."

                    POD_IMAGES=$(kubectl get pods \
                        -n etrm \
                        -l app=trade-service \
                        -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\\n"}{end}')

                    echo "${POD_IMAGES}"

                    if echo "${POD_IMAGES}" | grep -vFx "${EXPECTED_IMAGE}" | grep -q .; then
                        echo "ERROR: One or more pods are running an unexpected image."
                        exit 1
                    fi

                    echo "Checking application health..."

                    curl -fsS \
                        http://k8s-etrm-tradeser-caff546086-1568206008.ap-south-1.elb.amazonaws.com/actuator/health \
                        > health.json

                    cat health.json

                    grep -q '"status":"UP"' health.json

                    echo "Release validation completed successfully."
                '''
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
