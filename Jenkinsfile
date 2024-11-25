/*
pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image locally
                    sh 'docker build -t nodejs-docker-app .'
                    
                    // Save the Docker image as a tar file
                    sh 'docker save -o nodejs-docker-app.tar nodejs-docker-app'
                }
            }
        }

        stage('Deploy to Second EC2 Instance') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'SSHtoken', keyFileVariable: 'Key')]) {
                        // Copy the Docker image tar file to the EC2 instance
                        sh '''
                        scp -o StrictHostKeyChecking=no -i $Key nodejs-docker-app.tar ec2-user@65.0.134.255:/home/ec2-user/
                        '''

                        // SSH into the EC2 instance, load the image, and run the container
                        sh '''
                        ssh -o StrictHostKeyChecking=no -i $Key ec2-user@65.0.134.255 << 'ENDSSH'
docker load -i /home/ec2-user/nodejs-docker-app.tar
if [ $(docker ps -q -f name=nodejs-docker-container) ]; then
    docker stop nodejs-docker-container
    docker rm nodejs-docker-container
fi
docker run -d -p 8082:8082 --name nodejs-docker-container nodejs-docker-app
ENDSSH
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Node.js Docker application deployed successfully on the EC2 instance!'
        }
        failure {
            echo 'Deployment failed. Please check the logs for details.'
        }
    }
}
*/

/*
pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image locally
                    sh 'docker build -t nodejs-docker-app .'
                    
                    // Save the Docker image as a tar file
                    sh 'docker save -o nodejs-docker-app.tar nodejs-docker-app'
                }
            }
        }

        stage('Deploy to Second EC2 Instance') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'SSHtoken', keyFileVariable: 'Key')]) {
                        // Copy the Docker image tar file to the EC2 instance
                        sh '''
                        scp -o StrictHostKeyChecking=no -i $Key nodejs-docker-app.tar ec2-user@13.201.53.2:/home/ec2-user/
                        '''

                        // SSH into the EC2 instance, load the image, and run the container
                        sh '''
                        ssh -o StrictHostKeyChecking=no -i $Key ec2-user@13.201.53.218 << 'ENDSSH'
docker load -i /home/ec2-user/nodejs-docker-app.tar

# Stop and remove any existing container with the same name
docker rm -f nodejs-docker-container || true

# Run the new container
docker run -d -p 8081:8081 --name nodejs-docker-container nodejs-docker-app:latest
ENDSSH
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Node.js Docker application deployed successfully on the EC2 instance!'
        }
        failure {
            echo 'Deployment failed. Please check the logs for details.'
        }
    }
}
*/

pipeline {
    agent any

    environment {
        ACR_NAME = 'democontaineregistry.azurecr.io'
        IMAGE_NAME = 'sharks'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        AZURE_CREDENTIALS = 'azure'
        AZURE_REGISTRY = 'democontaineregistry.azurecr.io'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ACR_NAME}/${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Login to Azure ACR (First Method)') {
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'azure', usernameVariable: 'AZURE_USERNAME', passwordVariable: 'AZURE_PASSWORD')]) {
                sh """
                echo \$AZURE_PASSWORD | docker login \$ACR_NAME -u \$AZURE_USERNAME --password-stdin
                """
            }
        }
    }
}


        stage('Push Docker Image to ACR (First Method)') {
            steps {
                script {
                    dockerImage.push()
                }
            }
        }

        stage('Login to Azure ACR (Second Method)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-service-principal', usernameVariable: 'AZURE_USERNAME', passwordVariable: 'AZURE_PASSWORD')]) {
                    sh """
                        echo \$AZURE_PASSWORD | docker login \$AZURE_REGISTRY -u \$AZURE_USERNAME --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image to ACR (Second Method)') {
            steps {
                sh 'docker push democontaineregistry.azurecr.io/sharks:build-2'
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    sh """
                    docker stop sharks-container || true
                    docker rm sharks-container || true
                    docker run -d -p 8082:8082 --name sharks-container ${ACR_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up local Docker resources'
            sh 'docker system prune -f || true'
        }
        success {
            echo 'Build and deployment successful'
        }
        failure {
            echo 'Build or deployment failed'
        }
    }
}
