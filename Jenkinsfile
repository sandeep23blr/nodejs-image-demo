pipeline {
agent any

environment {
    AWS_REGION = "ap-south-1"
    ACCOUNT_ID = "953596634933"
    IMAGE_NAME = "kubernetes"
    ECR_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
    KUBECONFIG = "/var/jenkins_home/.kube/config"
}

stages {

    stage('Clean Workspace') {
        steps {
            cleanWs()
        }
    }

    stage('Clone Repository') {
        steps {
            git branch: 'development',
            url: 'https://github.com/sandeep23blr/nodejs-image-demo.git'
        }
    }

    stage('Build Docker Image') {
        steps {
            sh '''
            docker build -t $IMAGE_NAME .
            '''
        }
    }

    stage('Login to AWS ECR') {
        steps {
            withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'AWS_credentials'
            ]]) {
                sh '''
                aws ecr get-login-password --region $AWS_REGION \
                | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }
    }

    stage('Tag Docker Image') {
        steps {
            sh '''
            docker tag $IMAGE_NAME:latest $ECR_REPO:latest
            '''
        }
    }

    stage('Push Image to ECR') {
        steps {
            sh '''
            docker push $ECR_REPO:latest
            '''
        }
    }

    stage('Deploy to Kubernetes') {
        steps {
            sh '''
            export KUBECONFIG=$KUBECONFIG

            kubectl apply -f deployment.yml --validate=false
            kubectl apply -f service.yml --validate=false

            kubectl rollout restart deployment nodejs-app
            '''
        }
    }

}

post {
    success {
        echo "Deployment completed successfully!"
    }
    failure {
        echo "Pipeline failed. Check logs."
    }
}

}
