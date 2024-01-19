pipeline {
    agent any

    tools {
        maven "Maven3"
        jdk "jdk17"
    }
    
    environment {
        // Define environment variables
        NEXUS_VERSION = 'nexus3'
        NEXUS_REPOSITORY = 'kanban-backend'
        NEXUS_URL = 'nexus:8081'
        NEXUS_PROTOCOL = 'http'
        NEXUS_CREDENTIAL_ID = 'nexus_credentials'
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub_credentials'

        BACKEND_IMAGE_NAME = 'kanban-backend'
        DOCKERHUB_USER = 'medez'
    }

    stages {

        stage('Unit Test') {
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }

        stage('Package JAR') {
            steps {
                script {
                    sh 'mvn clean package'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube_token') {
                        sh "mvn sonar:sonar"
                    }
                }
            }
        }

        stage("Publish to Nexus") {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: BUILD_NUMBER,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }


        stage('Build and Push Docker Image') {
            steps {
                script {

                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh "docker login -u ${USERNAME} -p ${PASSWORD}"
                        sh "docker build -t ${DOCKERHUB_USER}/${BACKEND_IMAGE_NAME}:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKERHUB_USER}/${BACKEND_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKERHUB_USER}/${BACKEND_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKERHUB_USER}/${BACKEND_IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh "docker compose -p 'kanban' down || echo 'project kanban not running'"
                    sh "docker compose -p 'kanban' up -d --build"
                    slackSend color: "good", message: "Backend deployed Successfully!"
                }
            }
        }
    }

    post {
        always {
            
            script {
                sh "docker logout"
                echo 'Pipeline execution complete!'
            }
        }
        
        failure {
            slackSend color: "danger", message: "Backend pipeline failed."
        }
    }
}
