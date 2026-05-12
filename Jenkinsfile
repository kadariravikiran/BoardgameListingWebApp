pipeline {

    agent any

    tools {
        jdk 'JAVA'
        maven 'MAVEN'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
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

                sh 'docker build -t ravikirankadari/myapp:v1 .'

            }
        }

        stage('Trivy Image Scan') {
            steps {

                sh 'TMPDIR=/opt/trivy-tmp trivy image --scanners vuln ravikirankadari/myapp:v1'

            }
        }

        stage('Docker Push') {
            steps {

                withDockerRegistry(
                    credentialsId: 'docker-cred',
                    url: 'https://index.docker.io/v1/'
                ) {

                    sh 'docker push ravikirankadari/myapp:v1'

                }

            }
        }

        stage('Deploy To Kubernetes') {
            steps {

                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl apply -f service.yaml'

            }
        }

    }

}
