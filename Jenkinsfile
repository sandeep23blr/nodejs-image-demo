pipeline {
agent any

```
environment {
    AWS_REGION = "ap-south-1"
    ACCOUNT_ID = "953596634933"
    IMAGE_NAME = "kubernetes"
    ECR_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
}

stages {

    stage('Clone Repository') {
        steps {
            git branch: 'development', url: 'https://github.com/sandeep23blr/nodejs-image-demo.git'
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
            kubectl apply -f deployment.yml
            kubectl apply -f service.yml
            kubectl rollout restart deployment nodejs-app
            '''
        }
    }

}
```

}
