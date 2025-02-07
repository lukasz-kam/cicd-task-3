pipeline {
    agent any

    environment {

        PORT = "${env.BRANCH_NAME == 'main' ? '3000' : env.BRANCH_NAME == 'dev' ? '3001' : '5000'}"
        TRIVY_OUTPUT_FILE = "trivy_result-${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
        HADOLINT_OUTPUT_FILE = "hadolint_result-${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
        IMAGE_NAME = "node${env.BRANCH_NAME}:v1.0"
        DOCKER_USER = 'lucascx'
    }

    stages {
        stage('Build and test'){
            agent {
                docker {
                    image 'node:alpine3.20'
                }
            }
            stages {
                stage('Build'){
                    steps {
                        script {
                            echo "Build started..."
                            sh 'chmod +x ./scripts/build.sh'
                            sh '. ./scripts/build.sh'
                        }
                    }
                }
                stage('Test'){
                    steps {
                        script {
                            echo "Test started..."
                            sh 'chmod +x ./scripts/test.sh'
                            sh '. ./scripts/test.sh'
                        }
                    }
                }
            }
        }
        stage('Dockerfile lint'){
            agent {
                docker {
                    image 'hadolint/hadolint:latest-alpine'
                }
            }
            steps {
                sh "hadolint -f json Dockerfile > ${HADOLINT_OUTPUT_FILE}"
            }
            post {
                failure {
                    sh "cat ${HADOLINT_OUTPUT_FILE}"
                    archiveArtifacts artifacts: "${HADOLINT_OUTPUT_FILE}", fingerprint: true
                }
            }
        }
        stage('Docker build and push'){
            agent {
                docker {
                    image 'lucascx/trivy-docker:v1.0'
                    args '-v /var/run/docker.sock:/var/run/docker.sock --user 1000:999'
                }
            }
            environment {
                HOME = "${env.WORKSPACE}"
            }
            stages{
                stage('Build'){
                    steps {
                        script {
                            sh "docker build -t ${IMAGE_NAME} ."
                        }
                    }
                }
                stage('Trivy scan'){
                    steps {
                        script {
                            sh "trivy image --output ${TRIVY_OUTPUT_FILE} ${IMAGE_NAME}"
                            archiveArtifacts artifacts: "${TRIVY_OUTPUT_FILE}", allowEmptyArchive: true
                        }
                    }
                }
                stage('Push to dockerhub'){
                    steps {
                        script {
                            sh "docker tag $IMAGE_NAME $DOCKER_USER/$IMAGE_NAME"
                            withDockerRegistry([credentialsId: 'docker-lucascx', url: '']) {
                                sh "docker push $DOCKER_USER/$IMAGE_NAME"
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                def jobName = "Deploy_to_${env.BRANCH_NAME}"
                build job: jobName,
                    parameters: [
                        string(name: 'PORT', value: env.PORT),
                        string(name: 'ENVIRONMENT', value: env.BRANCH_NAME),
                        string(name: 'IMAGE_NAME', value: "$DOCKER_USER/$IMAGE_NAME")
                    ],
                    wait: false
            }
        }
    }
}