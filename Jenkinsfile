pipeline {
    agent any

    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        ECR_REPO = "476360959449.dkr.ecr.us-east-1.amazonaws.com/prod/devops"
        AWS_REGION = "us-east-1"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Checking out code from GitHub..."
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Workspace content:"
                ls -la

                echo "Building Docker image..."
                docker build -t my-app:${IMAGE_TAG} -f DevOps-Project-01/Java-Login-App/Dockerfile DevOps-Project-01/Java-Login-App
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                echo "Logging in to AWS ECR..."
                aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin 476360959449.dkr.ecr.us-east-1.amazonaws.com

                echo "Tagging & pushing image..."
                docker tag my-app:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                docker push ${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
            echo "Pipeline finished"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
        success {
            echo "✅ Image pushed to ECR successfully!"
        }
    }
}
