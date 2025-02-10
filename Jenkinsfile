pipeline {
    agent any
    environment {
        SONAR_PROJECT_KEY = 'demo'
        VERSION = "${env.BUILD_NUMBER}"
        NEXUS_CREDENTIALS_ID = 'nexus-credentials'
        NEXUS_URL = 'nexus_url'
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
        stage('Docker Build & Docker Push') {
            steps {
                    script {
                        // This step should not normally be used in your script. Consult the inline help for details.
                        withDockerRegistry([credentialsId: "${NEXUS_CREDENTIALS_ID}", url: "${NEXUS_URL}"]) {
                            '''docker build -t ${NEXUS_URL}/spring-demo:${VERSION} .
                            docker login ${NEXUS_CREDENTIALS_ID} ${NEXUS_URL}
                            docker push ${NEXUS_URL}/spring-demo:${VERSION}
                            docker rmi ${NEXUS_URL}/spring-demo:${VERSION}
                            '''
                        }
                    }
                }
            }

        }
    }
}
