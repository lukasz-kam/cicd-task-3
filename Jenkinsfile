pipeline {
    agent any

    environment {
        PORT = "${env.BRANCH_NAME == 'main' ? '3000' : env.BRANCH_NAME == 'dev' ? '3001' : '5000'}"
    }
    stages {
        stage('Build'){
            agent {
                docker {
                    image 'node:alpine3.20'
                    customWorkspace "/home/vagrant/workspace/${env.JOB_NAME}-${env.BRANCH_NAME}"
                }
            }

            steps {
                script {
                    echo "Build started..."
                    sh 'chmod +x ./scripts/build.sh'
                    sh '. ./scripts/build.sh'
                }
            }
        }
        stage('Test'){
            agent {
                docker {
                    customWorkspace "/home/vagrant/workspace/${env.JOB_NAME}-${env.BRANCH_NAME}"
                    image 'node:alpine3.20'
                }
            }
            steps {
                script {
                    echo "Test started..."
                    sh 'chmod +x ./scripts/test.sh'
                    sh '. ./scripts/test.sh'
                }
            }
        }
        stage('Docker build'){
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock --user 1000:999'
                    customWorkspace "/home/vagrant/workspace/${env.JOB_NAME}-${env.BRANCH_NAME}"
                }
            }
            environment {
                HOME = "${env.WORKSPACE}"
            }
            steps {
                script {
                    sh "docker build -t node${env.BRANCH_NAME}:v1.0 ."
                }
            }
        }
        stage('Deploy'){
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock --user 1000:999'
                    customWorkspace "/home/vagrant/workspace/${env.JOB_NAME}-${env.BRANCH_NAME}"
                }
            }
            environment {
                HOME = "${env.WORKSPACE}"
            }
            steps {
                script {
                    sh "docker ps -aq --filter label=env=${env.BRANCH_NAME} | xargs -r docker rm -f"
                    sh "docker run -d --label env=${env.BRANCH_NAME} --expose ${PORT} -p ${PORT}:3000 node${env.BRANCH_NAME}:v1.0"
                }
            }
        }
        stage('Cleanup'){
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock --user 1000:999'
                    customWorkspace "/home/vagrant/workspace/${env.JOB_NAME}-${env.BRANCH_NAME}"
                }
            }
            steps {
                script {
                    sh "docker image prune -f 2> /dev/null"
                    sh "docker volume prune -f 2> /dev/null"
                }
            }
        }
    }
}