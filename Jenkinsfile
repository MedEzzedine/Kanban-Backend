pipeline {
    agent any

    tools {
        mvn "Maven3"
    }
    
    environment {
        // Define environment variables
        NEXUS_VERSION = '1.0.0'
        NEXUS_REPOSITORY = 'your-nexus-repo'
        NEXUS_URL = 'http://your-nexus-server.com'
        NEXUS_CREDENTIALS_ID = 'nexus-credentials' // Jenkins credentials ID for Nexus
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials' // Jenkins credentials ID for DockerHub
        DOCKER_IMAGE = 'yourdockerhubuser/yourimage'
        SONARQUBE_SERVER = 'http://localhost:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                // Get the code from SCM (e.g., GitHub, Bitbucket)
                checkout scm
            }
        }

        stage('Compile and Unit Test') {
            steps {
                script {
                    // Run Maven build
                    sh 'mvn clean compile test'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube_token') {
                        sh "mvn sonar:sonar -Dsonar.host.url=${SONARQUBE_SERVER}"
                    }
                }
            }
        }

/*         stage('Publish to Nexus') {
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
