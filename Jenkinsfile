pipeline {
    agent any
    
    environment {
        // Docker Configuration
        DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME')
        DOCKERHUB_TOKEN = credentials('DOCKERHUB_TOKEN')
        DOCKER_IMAGE = "${DOCKERHUB_USERNAME}/todo-app"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    options {
        // Add timestamp to console output
        timestamps()
        
        // Timeout if pipeline runs for more than 1 hour
        timeout(time: 1, unit: 'HOURS')
    }
    
    stages {
        stage('Environment Debug') {
            steps {
                // Print environment info for debugging
                bat '''
                    @echo off
                    echo === Environment Information ===
                    echo Jenkins Workspace: %WORKSPACE%
                    echo Build Number: %BUILD_NUMBER%
                    echo Docker Image Base: %DOCKER_IMAGE%
                    
                    echo === Directory Structure ===
                    dir /b
                    
                    echo === System Information ===
                    systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
                    
                    echo === Available Tools ===
                    where docker 2>nul || echo Docker NOT FOUND
                    docker version || echo Docker version command failed
                    where node 2>nul || echo Node.js NOT FOUND
                    where npm 2>nul || echo NPM NOT FOUND
                '''
            }
        }
        
        stage('Directory Check') {
            steps {
                // Check if required directories exist
                bat '''
                    @echo off
                    echo Checking project directories...
                    
                    if exist frontend (
                        echo Frontend directory exists
                        dir frontend /b
                    ) else (
                        echo Frontend directory NOT FOUND
                        exit 1
                    )
                    
                    if exist auth-service (
                        echo Auth service directory exists
                        dir auth-service /b
                    ) else (
                        echo Auth service directory NOT FOUND
                        exit 1
                    )
                '''
            }
        }
        
        stage('Docker Check') {
            steps {
                // Basic Docker operations to verify functionality
                bat '''
                    @echo off
                    echo Testing Docker functionality...
                    
                    docker info || (
                        echo Docker daemon not responding
                        exit 1
                    )
                    
                    echo Creating test container...
                    docker run --rm hello-world || (
                        echo Failed to run test container
                        exit 1
                    )
                '''
            }
        }
        
        stage('Build Frontend Docker Image') {
            when {
                expression { return fileExists('frontend') }
            }
            steps {
                // Build frontend Docker image with error handling
                bat '''
                    @echo off
                    echo Building frontend Docker image...
                    
                    cd frontend || (
                        echo Failed to change to frontend directory
                        exit 1
                    )
                    
                    echo Contents of frontend directory:
                    dir /b
                    
                    if not exist Dockerfile (
                        echo Dockerfile not found in frontend directory
                        exit 1
                    )
                    
                    docker build -t %DOCKER_IMAGE%-frontend:%DOCKER_TAG% . || (
                        echo Frontend Docker build failed
                        exit 1
                    )
                    
                    docker tag %DOCKER_IMAGE%-frontend:%DOCKER_TAG% %DOCKER_IMAGE%-frontend:latest || (
                        echo Frontend Docker tag failed
                        exit 1
                    )
                    
                    echo Frontend Docker image built successfully
                '''
            }
        }
        
        stage('Build Backend Docker Image') {
            when {
                expression { return fileExists('auth-service') }
            }
            steps {
                // Build backend Docker image with error handling
                bat '''
                    @echo off
                    echo Building backend Docker image...
                    
                    cd auth-service || (
                        echo Failed to change to auth-service directory
                        exit 1
                    )
                    
                    echo Contents of auth-service directory:
                    dir /b
                    
                    if not exist Dockerfile (
                        echo Dockerfile not found in auth-service directory
                        exit 1
                    )
                    
                    docker build -t %DOCKER_IMAGE%-backend:%DOCKER_TAG% . || (
                        echo Backend Docker build failed
                        exit 1
                    )
                    
                    docker tag %DOCKER_IMAGE%-backend:%DOCKER_TAG% %DOCKER_IMAGE%-backend:latest || (
                        echo Backend Docker tag failed
                        exit 1
                    )
                    
                    echo Backend Docker image built successfully
                '''
            }
        }
        
        stage('Docker Hub Push') {
            when {
                expression { 
                    try {
                        bat(script: 'docker images | findstr %DOCKER_IMAGE%', returnStatus: true) == 0
                    } catch (Exception e) {
                        return false
                    }
                }
            }
            steps {
                // Login to Docker Hub and push images with error handling
                bat '''
                    @echo off
                    echo Pushing Docker images to Docker Hub...
                    
                    echo %DOCKERHUB_TOKEN% | docker login -u %DOCKERHUB_USERNAME% --password-stdin || (
                        echo Docker Hub login failed
                        exit 1
                    )
                    
                    echo Available Docker images:
                    docker images | findstr %DOCKER_IMAGE%
                    
                    echo Pushing frontend image...
                    docker push %DOCKER_IMAGE%-frontend:%DOCKER_TAG% || (
                        echo Failed to push frontend image with tag %DOCKER_TAG%
                        exit 1
                    )
                    
                    docker push %DOCKER_IMAGE%-frontend:latest || (
                        echo Failed to push frontend image with tag latest
                        exit 1
                    )
                    
                    echo Pushing backend image...
                    docker push %DOCKER_IMAGE%-backend:%DOCKER_TAG% || (
                        echo Failed to push backend image with tag %DOCKER_TAG%
                        exit 1
                    )
                    
                    docker push %DOCKER_IMAGE%-backend:latest || (
                        echo Failed to push backend image with tag latest
                        exit 1
                    )
                    
                    echo Docker images pushed successfully
                '''
            }
        }
    }
    
    post {
        always {
            // Print docker images and attempt cleanup
            bat '''
                @echo off
                echo === Docker Images ===
                docker images | findstr %DOCKER_IMAGE% || echo No matching images found
                
                echo === Cleaning up... ===
                docker system prune -f || echo Docker cleanup failed
            '''
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check the logs for details.'
        }
    }
}