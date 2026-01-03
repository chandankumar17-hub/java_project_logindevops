pipeline {
    agent any

    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        ECR_REPO = "476360959449.dkr.ecr.us-east-1.amazonaws.com/prod/devops"
        AWS_REGION = "us-east-1"
        K8S_NAMESPACE = "prod"
        K8S_DEPLOYMENT = "my-app"
        K8S_CONTAINER = "my-app"
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

        stage('Deploy to EKS') {
            steps {
                sh '''
                echo "Updating deployment image in EKS..."
                kubectl set image deployment/${K8S_DEPLOYMENT} ${K8S_CONTAINER}=${ECR_REPO}:${IMAGE_TAG} -n ${K8S_NAMESPACE}

                echo "Checking rollout status..."
                kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE} --timeout=120s
                '''
                echo "Deployment completed!"
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
            echo "✅ Image pushed and deployed to EKS successfully!"
        }
    }
}
