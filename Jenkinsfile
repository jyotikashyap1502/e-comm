pipeline {
    agent any
    
    environment {
        DOCKER_USERNAME = 'jyotikashyap1502'
        IMAGE_NAME = 'ecomm-react-app'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Determine Repository') {
            steps {
                script {
                    def branch = env.GIT_BRANCH ?: sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                    
                    echo "Current branch: ${branch}"
                    
                    if (branch.contains('main') || branch.contains('master')) {
                        env.REPO_TAG = 'prod'
                        echo '🔴 Building for PRODUCTION (prod repo)'
                    } else if (branch.contains('dev')) {
                        env.REPO_TAG = 'dev'
                        echo '🟢 Building for DEVELOPMENT (dev repo)'
                    } else {
                        env.REPO_TAG = 'dev'
                        echo '⚠️  Unknown branch, defaulting to DEV repo'
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "🔨 Building Docker image: ${IMAGE_NAME}:${env.REPO_TAG}"
                sh """
                    docker build -t ${IMAGE_NAME}:latest .
                    docker tag ${IMAGE_NAME}:latest ${DOCKER_USERNAME}/${IMAGE_NAME}:${env.REPO_TAG}
                """
                echo '✅ Docker image built successfully'
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo '🔑 Logging in to Docker Hub...'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                
                echo "📤 Pushing to Docker Hub: ${DOCKER_USERNAME}/${IMAGE_NAME}:${env.REPO_TAG}"
                sh "docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${env.REPO_TAG}"
                
                echo '✅ Image pushed to Docker Hub successfully'
            }
        }
        
        stage('Cleanup Local Images') {
            steps {
                echo '🧹 Cleaning up old images...'
                sh """
                    docker image prune -f
                """
            }
        }
    }
    
    post {
        always {
            echo '🔓 Logging out from Docker Hub...'
            sh 'docker logout || true'
        }
        success {
            echo '✅ =========================================='
            echo '✅ Pipeline completed successfully!'
            echo '✅ =========================================='
            echo "Branch: ${env.GIT_BRANCH}"
            echo "Image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${env.REPO_TAG}"
            echo "Docker Hub: https://hub.docker.com/r/${DOCKER_USERNAME}/${IMAGE_NAME}"
        }
        failure {
            echo '❌ =========================================='
            echo '❌ Pipeline failed! Check logs above.'
            echo '❌ =========================================='
        }
    }
}
