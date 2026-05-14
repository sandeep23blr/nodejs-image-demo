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
                        scp -o StrictHostKeyChecking=no -i $Key nodejs-docker-app.tar ec2-user@3.109.60.118:/home/ec2-user/
                        '''

                        // SSH into the EC2 instance, load the image, and run the container
                        sh '''
                        ssh -o StrictHostKeyChecking=no -i $Key ec2-user@3.109.60.118 << 'ENDSSH'
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
                        scp -o StrictHostKeyChecking=no -i $Key nodejs-docker-app.tar ec2-user@3.109.60.118:/home/ec2-user/
                        '''

                        // SSH into the EC2 instance, load the image, and run the container
                        sh '''
                        ssh -o StrictHostKeyChecking=no -i $Key ec2-user@3.109.60.118 << 'ENDSSH'
docker load -i /home/ec2-user/nodejs-docker-app.tar

# Stop and remove any existing container with the same name
docker rm -f nodejs-docker-container || true

# Run the new container
docker run -d -p 8082:8082 --name nodejs-docker-container nodejs-docker-app:latest
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

/*
pipeline {
    agent any

    environment {
        REGISTRY = 'sandeepcontianerregistry.azurecr.io' // Ensure correct registry address
        IMAGE_NAME = 'sharks'
        TAG = "build-${BUILD_NUMBER}"
        CONTAINER_NAME = 'sharks-container'
        CONTAINER_PORT = '8082'  // Change to your desired port
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${REGISTRY}/${IMAGE_NAME}:${TAG}"
                    sh "docker build -t ${REGISTRY}/${IMAGE_NAME}:${TAG} ."
                }
            }
        }

        stage('Login to Docker Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockercredentials', usernameVariable: 'Username', passwordVariable: 'Password')]) {
                    script {
                        echo "Logging in to Docker Registry"
                        sh """
                        echo "$Password" | docker login ${REGISTRY} -u "$Username" --password-stdin
                        """
                    }
                }
            }
        }

        stage('Push Docker Image to Registry') {
            steps {
                script {
                    echo "Pushing Docker image to registry"
                    sh "docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    echo "Stopping and removing any existing container with the name ${CONTAINER_NAME}"
                    sh "docker rm -f ${CONTAINER_NAME} || true"

                    echo "Deploying container from image ${REGISTRY}/${IMAGE_NAME}:${TAG}"
                    sh """
                        docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p ${CONTAINER_PORT}:${CONTAINER_PORT} \
                        ${REGISTRY}/${IMAGE_NAME}:${TAG}
                    """
                }
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning up local Docker resources'
                sh 'docker system prune -f'
            }
        }
    }

    post {
        failure {
            echo 'Build or deployment is failed'
        }
        success {
            echo 'Build and deployment is succeeded'
        }
    }
}
*/
