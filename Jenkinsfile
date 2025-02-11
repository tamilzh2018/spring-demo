pipeline {
    agent any
    environment {
        SONAR_PROJECT_KEY = 'demo'
        VERSION = "${env.BUILD_NUMBER}"
        NEXUS_CREDENTIALS_ID = 'Nexus-Credentials'
        DOCKER_PASSWORD = 'docker-password'
        DOCKER_USERNAME = 'docker-username'
        NEXUS_URL = 'nexus_url'
        DOCKER_REPO = 'Docker-Repo'
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
                                mvn sonar:sonar \
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
        stage('Maven Build') {
            steps {
                script {
                    sh "mvn clean package"
                }
            }
        }
        stage('Docker Build & Docker Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'Nexus-Credentials', passwordVariable: 'nexus-password', usernameVariable: 'nexus-username')]) {
                        sh """
                            docker build -t ${DOCKER_REPO}/spring-demo:${VERSION} .
                            if echo ${DOCKER_PASSWORD} | docker login --username ${DOCKER_USERNAME} --password-stdin ${DOCKER_REPO}; then
                                echo "Login successful!"
                                else
                                echo "Login failed."
                            fi
                            docker push ${DOCKER_REPO}/spring-demo:${VERSION}
                            docker rmi ${DOCKER_REPO}/spring-demo:${VERSION}
                        """
                    }
                }
            }
        }
    }
}
