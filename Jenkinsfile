pipeline {
    agent any
    environment {
        SONAR_PROJECT_KEY = 'demo'
        VERSION = "${env.BUILD_NUMBER}"
        NEXUS_CREDENTIALS_ID = 'Nexus-Credentials'
        DOCKER_PASSWORD = 'docker-password'
        DOCKER_USERNAME = 'docker-username'
        NEXUS_URL = 'nexus_url'
        DOCKER_REPO = 'docker-repo'
    }
    stages {
        stage("git checkout") {
            steps {
                git 'https://github.com/tamilzh2018/spring-demo.git'
            }
        }
        /* stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        } */
        stage("Sonar Quality Analysis") {
            /* agent {
                docker {
                    image 'maven:3-openjdk-17'
                }
            } */
            steps {
                script {
                    withCredentials([string(credentialsId: "sonar-token", variable: "SONAR_TOKEN"), string(credentialsId: "sonar-server-url", variable: "SONAR_HOST_URL")]) {
                        echo "Running SonarQube Analysis"
                        withSonarQubeEnv('SonarQube') {
                            sh """
                                mvn clean install sonar:sonar \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=${SONAR_TOKEN}
                            """
                        }
                    }
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        /* stage('Maven Build') {
            steps {
                script {
                    sh "mvn clean package"
                }
            }
        } */
        stage('Docker Build & Docker Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'Nexus-Credentials', passwordVariable: 'nexus-password', usernameVariable: 'nexus-username')]) {
                        sh """
                            docker build -t 10.0.0.130:8083/spring-demo:${VERSION} .
                            if echo ${DOCKER_PASSWORD} | docker login --username ${DOCKER_USERNAME} --password-stdin 10.0.0.130:8083; then
                                echo "Login successful!"
                                else
                                echo "Login failed."
                            fi
                            docker push 10.0.0.130:8083/spring-demo:${VERSION}
                            docker rmi 10.0.0.130:8083/spring-demo:${VERSION}
                        """
                    }
                }
            }
        }
    }
}
