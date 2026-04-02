// pipeline {
// agent any

// environment {
//     AWS_REGION = "ap-south-1"
//     ACCOUNT_ID = "953596634933"
//     IMAGE_NAME = "kubernetes"
//     ECR_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
//     KUBECONFIG = "/var/jenkins_home/.kube/config"
// }

// stages {

//     stage('Clean Workspace') {
//         steps {
//             cleanWs()
//         }
//     }

//     stage('Clone Repository') {
//         steps {
//             git branch: 'development',
//             url: 'https://github.com/sandeep23blr/nodejs-image-demo.git'
//         }
//     }

//     stage('Build Docker Image') {
//         steps {
//             sh '''
//             docker build -t $IMAGE_NAME .
//             '''
//         }
//     }

//     stage('Login to AWS ECR') {
//         steps {
//             withCredentials([[
//                 $class: 'AmazonWebServicesCredentialsBinding',
//                 credentialsId: 'AWS_credentials'
//             ]]) {
//                 sh '''
//                 aws ecr get-login-password --region $AWS_REGION \
//                 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
//                 '''
//             }
//         }
//     }

//     stage('Tag Docker Image') {
//         steps {
//             sh '''
//             docker tag $IMAGE_NAME:latest $ECR_REPO:latest
//             '''
//         }
//     }

//     stage('Push Image to ECR') {
//         steps {
//             sh '''
//             docker push $ECR_REPO:latest
//             '''
//         }
//     }

//     stage('Deploy to Kubernetes') {
//         steps {
//             sh '''
//             export KUBECONFIG=$KUBECONFIG

//             kubectl apply -f deployment.yml --validate=false
//             kubectl apply -f service.yml --validate=false

//             kubectl rollout restart deployment nodejs-app
//             '''
//         }
//     }

// }

// post {
//     success {
//         echo "Deployment completed successfully!"
//     }
//     failure {
//         echo "Pipeline failed. Check logs."
//     }
// }

// }

pipeline {
    agent any

    environment {
        PROJECT_ID = "minicrm-491508"
        REGION = "asia-south1"
        REPO = "mini-crm"

        IMAGE_NAME = "mini-crm"
        CONTAINER_NAME = "test-node"

        CONTAINER_PORT = "8082"
        HOST_PORT = "8082"

        IMAGE_URI = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Configure Docker Auth') {
            steps {
                sh '''
                rm -rf ~/.docker
                mkdir -p ~/.docker
                gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def hash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.TAG = "${hash}-${BUILD_NUMBER}"

                    echo "Building image with tag: ${TAG}"

                    sh "docker build -t ${IMAGE_NAME}:${TAG} ."
                }
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh '''
                docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_URI}:${TAG}
                docker push ${IMAGE_URI}:${TAG}
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                script {

                    def exists = sh(
                        script: "docker ps -a --filter 'name=${CONTAINER_NAME}' --format '{{.Names}}'",
                        returnStdout: true
                    ).trim()

                    if (exists == "${CONTAINER_NAME}") {
                        echo "Stopping existing container..."
                        sh '''
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                        '''
                    }

                    sh "docker pull ${IMAGE_URI}:${TAG}"

                    sh '''
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        --restart=always \
                        ${IMAGE_URI}:${TAG}
                    '''
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                echo "Cleaning unused containers..."
                docker container prune -f

                echo "Cleaning unused images..."
                docker image prune -f
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
