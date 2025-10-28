pipeline {
    agent any

    environment {
        DOCKER_USERNAME = 'jyotikashyap1502'
        IMAGE_NAME = 'ecomm-react-app'
        DOCKERHUB_CREDENTIALS = credentials('jenkins-token-pat')
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code from GitHub...'
                checkout scm
            }
        }

        stage('Set Branch Name') {
            steps {
                script {
                    env.GIT_BRANCH = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                    echo "Detected branch name: ${env.GIT_BRANCH}"
                }
            }
        }

        stage('Determine Repository') {
            steps {
                script {
                    def branch = env.GIT_BRANCH
                    if (branch.contains('main') || branch.contains('master')) {
                        env.REPO_TAG = 'prod'
                        echo '🔴 Building for PRODUCTION (prod repo)'
                    } else if (branch.contains('dev')) {
                        env.REPO_TAG = 'dev'
                        echo '🟢 Building for DEVELOPMENT (dev repo)'
                    } else {
                        env.REPO_TAG = 'dev'
                        echo '⚠️ Unknown branch, defaulting to DEV repo'
                    }
                    echo "🧾 Docker tag to be pushed: ${DOCKER_USERNAME}/${IMAGE_NAME}:${env.REPO_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:latest .
                    docker tag ${IMAGE_NAME}:latest ${DOCKER_USERNAME}/${IMAGE_NAME}:${env.REPO_TAG}
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh "docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${env.REPO_TAG}"
            }
        }

        stage('Cleanup Local Images') {
            steps {
                sh 'docker image prune -f'
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed! Check logs.'
        }
    }
}
