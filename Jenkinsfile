@Library('Jenkins-Shared-Library') _
pipeline {
    agent any
    environment {
        SONAR_PROJECT_KEY = 'demo'
    }
    stages {
        stage("git checkout") {
            steps {
                git 'https://github.com/tamilzh2018/spring-demo.git'
            }
        }
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage("Sonar Quality Analysis") {
            agent {
                docker {
                    image 'maven:3-openjdk-17'
                }
            }
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN'), string(credentialsId: 'sonar-server-url', variable: 'SONAR_HOST_URL')]) {
                    echo "Running SonarQube Analysis"
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                    timeout(time: 5, unit: 'MINUTES') {
    
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                    
                }
            }
        }

    }
}
