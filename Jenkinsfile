pipeline {
    agent any
    environment {
        SONAR_PROJECT_KEY = 'demo'
        VERSION = "${env.BUILD_NUMBER}"
        NEXUS_CREDENTIALS_ID = 'Nexus-Credentials'
        

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
        /* stage('Quality Gate') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        } */
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
                    withCredentials([
                        string(credentialsId: 'docker-username', variable: 'DOCKER_USER'),
                        string(credentialsId: 'docker-password', variable: 'DOCKER_PASS'),
                        string(credentialsId: 'docker-repo', variable: 'DOCKER_URL')
                    ]) {
                            // Access the variables here
                            sh """
                            docker build -t ${env.DOCKER_URL}/spring-demo:${VERSION} .
                            if echo ${env.DOCKER_PASS} | docker login --username ${env.DOCKER_USER} --password-stdin ${env.DOCKER_URL}; then
                                echo "Login successful!"
                                else
                                echo "Login failed."
                            fi
                            docker push ${env.DOCKER_URL}/spring-demo:${VERSION}
                            docker rmi ${env.DOCKER_URL}/spring-demo:${VERSION}
                        """
                        }
                        
                    
                }
            }
        }
        stage('indentifying helm file misconfigs using datree/trivy'){
            steps{
                script{
                        dir('kubernetes/') {
                        //withEnv(['DATREE_TOKEN=<your-account-token> from datree.io']) {
                              //sh 'datree test demo-app/'} docker image scan:trivy image $APP_NAME:latest or trivy image --severity HIGH,CRITICAL <your-container-image>
                              sh 'trivy config demo-app/'
                        }

                    }
                }
        }
        stage('Push Helm Chart to Nexus') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(credentialsId: "${NEXUS_CREDENTIALS_ID}", usernameVariable: 'HELM_USER', passwordVariable: 'HELM_PASS'),
                        string(credentialsId: 'helm-url', variable: 'HELM_URL')
                    ]) {
                        dir('kubernetes/') {
                            sh '''
                            chartversion=$( helm show chart demo-app | grep version | cut -d: -f 2 | tr -d ' ')
                            helm package demo-app                            
                            curl -u ${HELM_USER}:${HELM_PASS} ${HELM_URL} --upload-file demo-app-${chartversion}.tgz -v
                            '''
                        //tar -xvf demo-app-${chart-version}.tgz demo-app/
                       }
                    }
                }
            }
        }
        stage('Kubernetes Validation throgh Kubernetes CLI plugin') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'k8s-jenkins-config', serverUrl: '']) {
                        dir('kubernetes/') {
                            sh """ 
                            helm upgrade --install --set image.repository="${env.DOCKER_URL}/spring-demo" --set image.tag="${VERSION}" spring-demo demo-app/
                            """
                        }    
                    }
                }
               
            }
        }
    }
}
