pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'emspo/mspots_be'
        DOCKER_TAG = 'dev3400'
        DEPLOY_SERVER = '185.93.166.49'
        GIT_BRANCH = 'server/dev-3400'
        PROJECT_NAME = 'BE 3400'
        JENKINS_PIPELINE_NAME = 'emspo-be-dev-3400'
    }

    stages {
        stage('Clone Repository') {
            steps {
                withCredentials([string(credentialsId: 'discord-deployment-webhook-url', variable: 'DISCORD_WEBHOOK')]) {
                    sh """
                        curl -H "Content-Type: application/json" -X POST -d '{\"content\":\":arrow_down: **${PROJECT_NAME}** Starting Clone Repository stage\"}' \$DISCORD_WEBHOOK
                    """
                }
                git credentialsId: 'github-creds-id', url: 'https://github.com/emspo/emspo-be.git', branch: "${GIT_BRANCH}"
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'docker-hub-creds-id', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS'),
                    string(credentialsId: 'discord-deployment-webhook-url', variable: 'DISCORD_WEBHOOK')
                ]) {
                    sh """
                        curl -H "Content-Type: application/json" -X POST -d '{\"content\":\":whale: **${PROJECT_NAME}** Starting Build Docker Image stage\"}' \$DISCORD_WEBHOOK
                        echo "\$DOCKERHUB_PASS" | docker login -u "\$DOCKERHUB_USER" --password-stdin
                        cd /var/lib/jenkins/workspace/${JENKINS_PIPELINE_NAME}/Docker
                        sh ./build-script.sh "${DOCKER_TAG}"
                    """
                }
            }
        }

        stage('Trigger Deployment') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'development-server-password-id', usernameVariable: 'DEPLOY_USER', passwordVariable: 'DEPLOY_PASS'),
                    string(credentialsId: 'discord-deployment-webhook-url', variable: 'DISCORD_WEBHOOK')
                ]) {
                    sh """
                        curl -H "Content-Type: application/json" -X POST -d '{\"content\":\":rocket: **${PROJECT_NAME}** Starting Trigger Deployment stage\"}' \$DISCORD_WEBHOOK
                        sshpass -p "\$DEPLOY_PASS" ssh -p 55000 -o StrictHostKeyChecking=no \$DEPLOY_USER@\$DEPLOY_SERVER 'cd /root/docker && sh pull-deploy-compose.sh ${DOCKER_TAG}'
                    """
                }
            }
        }
    }

    post {
        success {
            withCredentials([string(credentialsId: 'discord-deployment-webhook-url', variable: 'DISCORD_WEBHOOK')]) {
                sh """
                    curl -H "Content-Type: application/json" -X POST -d '{\"content\":\":white_check_mark: **${PROJECT_NAME}** Deployment completed successfully.\"}' \$DISCORD_WEBHOOK
                """
            }
            echo 'Deployment completed successfully.'
        }
        failure {
            withCredentials([string(credentialsId: 'discord-deployment-webhook-url', variable: 'DISCORD_WEBHOOK')]) {
                sh """
                    curl -H "Content-Type: application/json" -X POST -d '{\"content\":\":x: **${PROJECT_NAME}** Deployment failed.\"}' \$DISCORD_WEBHOOK
                """
            }
            echo 'Deployment failed.'
        }
    }
}
