
pipeline {

    agent any

    tools {
        jdk 'JAVA'
        maven 'MAVEN'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'

        AWS_REGION = 'us-east-1'
        ACCOUNT_ID = '123456789012'
        ECR_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my-app"
        IMAGE_TAG = "v1.0.${BUILD_NUMBER}"
    }

    stages {

        stage('Clone Code') {
            steps {
                git(
                    branch: 'main',
                    url: 'https://github.com/kadariravikiran/BoardgameListingWebApp.git',
                    credentialsId: 'git-cred'
                )
            }
        }

        stage('Build Maven') {
            steps {
                withMaven(
                    maven: 'MAVEN',
                    globalMavenSettingsConfig: 'global-settings'
                ) {
                    sh 'mvn clean package'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectKey=boardgame-app \
                    -Dsonar.projectName=boardgame-app \
                    -Dsonar.sources=. \
                    -Dsonar.java.binaries=target
                    '''
                }
            }
        }

        stage('Trivy File Scan') {
            steps {
                sh 'trivy fs .'
            }
        }

        stage('Upload To Nexus') {
            steps {
                withMaven(
                    maven: 'MAVEN',
                    globalMavenSettingsConfig: 'global-settings'
                ) {
                    sh 'mvn deploy'
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t my-app .'
            }
        }

        stage('Tag Image for ECR') {
            steps {
                sh 'docker tag my-app:latest $ECR_REPO:$IMAGE_TAG'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS \
                --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh 'docker push $ECR_REPO:$IMAGE_TAG'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'TMPDIR=/opt/trivy-tmp trivy image $ECR_REPO:$IMAGE_TAG'
            }
        }

        stage('Deploy To Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/myapp myapp=$ECR_REPO:$IMAGE_TAG
                kubectl rollout status deployment/myapp
                '''
            }
        }
    }
}
