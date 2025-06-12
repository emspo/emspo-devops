pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'emspo/mspots_fe'
        DOCKER_TAG = 'jenkintest'
        DEPLOY_SERVER = 'deployuser@your.deploy.server.ip'
        DEPLOY_PATH = '/path/on/deployment/server'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'github-creds-id', url: 'https://github.com/emspo/emspo-fe.git', branch: 'release'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE_NAME}:${DOCKER_TAG}", '--build-arg NODE_ENV=production .')
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-creds-id') {
                        docker.image("${DOCKER_IMAGE_NAME}:${DOCKER_TAG}").push()
                    }
                }
            }
        }

        // stage('Trigger Deployment') {
        //     steps {
        //         sshagent(['deploy-server-ssh-key']) {
        //             sh """
        //             ssh -o StrictHostKeyChecking=no $DEPLOY_SERVER << 'EOF'
        //                 cd $DEPLOY_PATH
        //                 docker compose pull
        //                 docker compose up -d
        //             EOF
        //             """
        //         }
        //     }
        // }
    }

    post {
        success {
            echo 'Deployment completed successfully.'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
