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
        REPO = "docker-images"

        IMAGE_NAME = "shark"
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

        stage('Build Docker Image') {
            steps {
                script {
                    def hash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.TAG = "${hash}-${BUILD_NUMBER}"

                    sh "docker build -t ${IMAGE_NAME}:${TAG} ."
                }
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh '''
                set -e

                echo "Getting token from metadata..."

                TOKEN=$(curl -s -H "Metadata-Flavor: Google" \
                http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token \
                | sed -n 's/.*"access_token":"\\([^"]*\\)".*/\\1/p')

                echo "Docker login using token..."

                echo $TOKEN | docker login -u oauth2accesstoken --password-stdin https://${REGION}-docker.pkg.dev

                echo "Tagging image..."
                docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_URI}:${TAG}

                echo "Pushing image..."
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
                docker container prune -f
                docker image prune -f
                '''
            }
        }
    }
}
