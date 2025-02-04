pipeline {
    agent any

    environment {
        PORT = "${env.BRANCH_NAME == 'main' ? '3000' : env.BRANCH_NAME == 'dev' ? '3001' : '5000'}"
    }
    stages {
        stage('Test') {
            steps {
                echo "Branch name is: ${GIT_BRANCH}"
                echo "PORT name is: ${PORT}"
            }
        }
        stage('Build') {
            steps {
                echo 'Testing...'
            }
        }
        stage('Docker build') {
            steps {
                echo 'Building...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Building...'
            }
        }
    }
}