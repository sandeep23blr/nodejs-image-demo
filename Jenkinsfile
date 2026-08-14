pipeline {
    agent any

    environment {
        IMAGE_NAME = "interntest"
        IMAGE_TAG = "${BUILD_NUMBER}"

        CONTAINER_NAME = "intern"

        HOST_PORT = "8082"
        CONTAINER_PORT = "8082"

        GIT_BRANCH = "main"
        GIT_REPOSITORY = "https://github.com/sandeep23blr/nodejs-image-demo.git"
        GIT_CREDENTIALS = "gitcred"
    }

    stages {

        stage('Checkout Latest Code') {
            steps {
                echo "========================================"
                echo "Checking Out Latest Code"
                echo "========================================"

                git(
                    branch: "${GIT_BRANCH}",
                    credentialsId: "${GIT_CREDENTIALS}",
                    url: "${GIT_REPOSITORY}"
                )
            }
        }

        stage('Verify Source Code') {
            steps {
                sh '''
                    echo "========================================"
                    echo "Workspace"
                    echo "========================================"

                    pwd

                    echo ""
                    echo "Files:"
                    ls -la

                    echo ""
                    echo "Git Commit:"
                    git log -1 --oneline

                    echo ""
                    echo "Dockerfile:"
                    ls -l Dockerfile
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "========================================"
                    echo "Building Docker Image"
                    echo "========================================"

                    docker build \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        .

                    echo ""
                    echo "Docker Image Created:"
                    docker images ${IMAGE_NAME}
                '''
            }
        }

        stage('Stop Existing Container') {
            steps {
                sh '''
                    echo "========================================"
                    echo "Stopping Existing Container"
                    echo "========================================"

                    docker stop ${CONTAINER_NAME} || true
                '''
            }
        }

        stage('Remove Existing Container') {
            steps {
                sh '''
                    echo "========================================"
                    echo "Removing Existing Container"
                    echo "========================================"

                    docker rm ${CONTAINER_NAME} || true
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                    echo "========================================"
                    echo "Starting New Container"
                    echo "========================================"

                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        ${IMAGE_NAME}:${IMAGE_TAG}

                    echo ""
                    echo "Container Started Successfully."

                    docker ps --filter "name=${CONTAINER_NAME}"
                '''
            }
        }

        stage('Cleanup Old Images') {
            steps {
                sh '''
                    echo "========================================"
                    echo "Cleaning Old Docker Images"
                    echo "========================================"

                    docker images ${IMAGE_NAME} \
                        --format "{{.Repository}}:{{.Tag}}" \
                    | grep -v "^${IMAGE_NAME}:${IMAGE_TAG}$" \
                    | xargs -r docker rmi || true

                    echo ""
                    echo "Remaining Images:"
                    docker images ${IMAGE_NAME}
                '''
            }
        }
    }

    post {

        success {
            echo """
            ==========================================
              DEPLOYMENT SUCCESSFUL
            ==========================================

            Build Number : ${BUILD_NUMBER}
            Image        : ${IMAGE_NAME}:${IMAGE_TAG}
            Container    : ${CONTAINER_NAME}
            Port         : ${HOST_PORT}:${CONTAINER_PORT}

            ==========================================
            """
        }

        failure {
            echo """
            ==========================================
              DEPLOYMENT FAILED
            ==========================================

            Build Number : ${BUILD_NUMBER}
            Image        : ${IMAGE_NAME}:${IMAGE_TAG}
            Container    : ${CONTAINER_NAME}

            ==========================================
            """

            sh '''
                echo "========================================"
                echo "Container Status"
                echo "========================================"

                docker ps -a \
                    --filter "name=${CONTAINER_NAME}" || true

                echo ""
                echo "========================================"
                echo "Container Logs"
                echo "========================================"

                docker logs --tail 200 \
                    ${CONTAINER_NAME} 2>&1 || true
            '''
        }
    }
}
