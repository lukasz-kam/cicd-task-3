pipeline {
    agent any

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
        stage('Docker build, deploy and cleanup '){
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock --user 1000:999'
                }
            }
            environment {
                HOME = "${env.WORKSPACE}"
                PORT = "${env.BRANCH_NAME == 'main' ? '3000' : env.BRANCH_NAME == 'dev' ? '3001' : '5000'}"
            }
            stages{
                stage('Build'){
                    steps {
                        script {
                            sh "docker build -t node${env.BRANCH_NAME}:v1.0 ."
                        }
                    }
                }

                stage('Deploy'){
                    steps {
                        script {
                            sh "docker ps -aq --filter label=env=${env.BRANCH_NAME} | xargs -r docker rm -f"
                            sh "docker run -d --label env=${env.BRANCH_NAME} --expose ${PORT} -p ${PORT}:3000 node${env.BRANCH_NAME}:v1.0"
                        }
                    }
                }
                stage('Cleanup'){
                    steps {
                        script {
                            sh "docker image prune -f 2> /dev/null"
                            sh "docker volume prune -f 2> /dev/null"
                        }
                    }
                }
            }
        }
    }
}