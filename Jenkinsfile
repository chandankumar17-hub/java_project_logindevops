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
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t my-app:${IMAGE_TAG} .
                '''
            }
        }

        stage('Trivy Scan (Image Lint)') {
            steps {
                sh '''
                    echo "Running Trivy scan..."
                    trivy image --exit-code 0 --severity HIGH,CRITICAL --no-progress --format table my-app:${IMAGE_TAG}
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                    echo "Logging in to ECR..."
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
            echo "❌ Trivy scan or ECR push failed!"
        }
        success {
            echo "✅ Image scanned and pushed to ECR successfully!"
        }
    }
}
