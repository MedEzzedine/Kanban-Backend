pipeline {
    agent any

    tools {
        maven "Maven3"
        jdk "jdk17"
    }
    
    environment {
        // Define environment variables
        NEXUS_VERSION = 'nexus3'
        NEXUS_REPOSITORY = 'devops-repo'
        NEXUS_URL = 'nexus:8081'
        NEXUS_PROTOCOL = 'http'
        NEXUS_CREDENTIAL_ID = 'nexus_credentials' // Jenkins credentials ID for Nexus
        //DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials' // Jenkins credentials ID for DockerHub
        //DOCKER_IMAGE = 'yourdockerhubuser/yourimage'
        //SONARQUBE_SERVER = 'http://sonarqube:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                // Get the code from SCM (e.g., GitHub, Bitbucket)
                cleanWs()
                checkout scm
                //git branch: 'main', credentialsId: 'github_credentials', url: 'https://github.com/MedEzzedine/Kanban-Backend'
            }
        }

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



        stage("Publish to Nexus Repository Manager") {
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
                            version: pom.version,
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
/*        
         stage('Publish to Nexus') {
            steps {
                script {
                    // Publish artifact to Nexus
                    sh "mvn deploy:deploy-file -Durl=${NEXUS_URL}/repository/${NEXUS_REPOSITORY}/ -DrepositoryId=${NEXUS_CREDENTIALS_ID} -Dfile=target/your-artifact-${NEXUS_VERSION}.jar -DgroupId=your.group -DartifactId=your-artifact -Dversion=${NEXUS_VERSION} -Dpackaging=jar"
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Login to DockerHub
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                        sh "echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin"
                    }

                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE}:${NEXUS_VERSION} ."

                    // Push Docker image to DockerHub
                    sh "docker push ${DOCKER_IMAGE}:${NEXUS_VERSION}"
                }
            }
        } */
    }

    post {
        always {
            // Actions to perform after the pipeline completes
            echo 'Pipeline execution complete!'
        }
    }
}
