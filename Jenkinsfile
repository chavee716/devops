pipeline {
    agent any
    
    environment {
        // Jenkins Configuration
        JENKINS_CREDS = credentials('jenkins-credentials')
        
        // AWS Credentials
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION           = credentials('AWS_REGION')
        
        // Additional AWS Configuration
        AWS_VPC_CIDR         = credentials('AWS_VPC_CIDR')
        AWS_SUBNET_CIDR      = credentials('AWS_SUBNET_CIDR')
        AWS_INSTANCE_TYPE    = credentials('AWS_INSTANCE_TYPE')
        AWS_AMI_ID          = credentials('AWS_AMI_ID')
        AWS_SECURITY_GROUP_NAME = credentials('AWS_SECURITY_GROUP_NAME')
        SSH_ALLOWED_IPS     = credentials('SSH_ALLOWED_IPS')
        
        // Docker Configuration
        DOCKERHUB_CREDS     = credentials('dockerhub-credentials')
        DOCKER_REGISTRY     = credentials('DOCKER_REGISTRY')
        DOCKER_BUILD_ARGS   = credentials('DOCKER_BUILD_ARGS')
        DOCKER_IMAGE        = "${env.DOCKER_REGISTRY ?: DOCKERHUB_CREDS_USR}/todo-app"
        DOCKER_TAG          = "${BUILD_NUMBER}"
        
        // EC2 Configuration
        EC2_HOST           = credentials('EC2_HOST')
        EC2_SSH_KEY        = credentials('EC2_SSH_KEY')
        EC2_USERNAME       = credentials('EC2_USERNAME')
        
        // Application Configuration
        APP_ENV           = credentials('APP_ENV')
        NODE_ENV          = credentials('NODE_ENV')
        APP_PORT          = credentials('APP_PORT')
        AUTH_SERVICE_PORT = credentials('AUTH_SERVICE_PORT')
        APP_SECRET_KEY    = credentials('APP_SECRET_KEY')
    }
    
    options {
        // Add timestamp to console output
        timestamps()
        
        // Timeout if pipeline runs for more than 1 hour
        timeout(time: 1, unit: 'HOURS')
        
        // Keep build logs and artifacts for last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('Setup') {
            steps {
                // Configure Jenkins credentials
                withCredentials([usernamePassword(credentialsId: 'jenkins-credentials', 
                               usernameVariable: 'JENKINS_USER', 
                               passwordVariable: 'JENKINS_TOKEN')]) {
                    sh '''
                        curl -X POST ${JENKINS_URL}/crumbIssuer/api/xml \
                            --user ${JENKINS_USER}:${JENKINS_TOKEN} > /dev/null 2>&1 || true
                    '''
                }
                
                // Install Node.js
                sh '''
                    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                '''
                
                // Install dependencies for both services
                sh '''
                    cd frontend && npm install
                    cd ../auth-service && npm install
                '''
                
                // Install required tools
                sh '''
                    curl -fsSL https://get.docker.com -o get-docker.sh
                    sudo sh get-docker.sh
                    sudo apt-get install -y ansible terraform awscli
                '''
                
                // Configure AWS CLI
                sh '''
                    aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                    aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                    aws configure set region ${AWS_REGION}
                '''
            }
        }
        
        stage('Test') {
            steps {
                // Run tests for both services
                sh '''
                    cd frontend && npm test
                    cd ../auth-service && npm test
                '''
            }
        }
        
        stage('Security Scan') {
            steps {
                // Run security audit
                sh '''
                    cd frontend && npm audit
                    cd ../auth-service && npm audit
                '''
            }
        }
        
        stage('Build') {
            steps {
                // Build frontend
                sh 'cd frontend && npm run build'
                
                // Build Docker image
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                '''
            }
        }
        
        stage('Docker Hub Push') {
            steps {
                // Login to Docker Hub using credentials
                sh '''
                    echo ${DOCKERHUB_TOKEN} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }
        
        stage('Terraform Infrastructure') {
            steps {
                // Create terraform.tfvars file with additional variables
                sh '''
                    cd terraform
                    cat << EOF > terraform.tfvars
                    aws_region = "${AWS_REGION}"
                    environment = "${APP_ENV}"
                    vpc_cidr = "${AWS_VPC_CIDR}"
                    subnet_cidr = "${AWS_SUBNET_CIDR}"
                    instance_type = "${AWS_INSTANCE_TYPE}"
                    ami_id = "${AWS_AMI_ID}"
                    security_group_name = "${AWS_SECURITY_GROUP_NAME}"
                    ssh_allowed_ips = "${SSH_ALLOWED_IPS}"
                    EOF
                '''
                
                // Initialize and apply Terraform
                sh '''
                    cd terraform
                    terraform init
                    terraform plan -out=tfplan
                    terraform apply -auto-approve tfplan
                '''
                
                // Save EC2 IP for Ansible
                sh '''
                    cd terraform
                    terraform output -raw instance_public_ip > ../ansible/ec2_ip.txt
                '''
            }
        }
        
        stage('Ansible Configuration') {
            steps {
                // Create Ansible inventory file
                sh '''
                    cd ansible
                    echo "[app_servers]" > inventory.ini
                    echo "app_server ansible_host=${EC2_HOST} ansible_user=${EC2_USERNAME} ansible_ssh_private_key_file=\${EC2_SSH_KEY}" >> inventory.ini
                '''
                
                // Create SSH key file
                sh '''
                    mkdir -p ~/.ssh
                    echo "${EC2_SSH_KEY}" > ~/.ssh/ec2_key.pem
                    chmod 600 ~/.ssh/ec2_key.pem
                '''
                
                // Run Ansible playbook with additional variables
                sh '''
                    cd ansible
                    ansible-playbook -i inventory.ini deploy.yml \\
                        -e "docker_image=${DOCKER_IMAGE}" \\
                        -e "docker_tag=${DOCKER_TAG}" \\
                        -e "docker_username=${DOCKERHUB_USERNAME}" \\
                        -e "docker_password=${DOCKERHUB_TOKEN}" \\
                        -e "app_env=${APP_ENV}" \\
                        -e "node_env=${NODE_ENV}" \\
                        -e "app_port=${APP_PORT}" \\
                        -e "auth_service_port=${AUTH_SERVICE_PORT}" \\
                        -e "app_secret_key=${APP_SECRET_KEY}"
                '''
            }
        }
    }
    
    post {
        always {
            // Clean up credentials and workspace
            sh '''
                rm -f ~/.ssh/ec2_key.pem
                docker logout
                aws configure set aws_access_key_id ""
                aws configure set aws_secret_access_key ""
            '''
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
            // Send success notification if needed
            emailext (
                subject: "Pipeline Success: ${currentBuild.fullDisplayName}",
                body: "The pipeline completed successfully.",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
        failure {
            echo 'Pipeline failed!'
            // Send failure notification if needed
            emailext (
                subject: "Pipeline Failed: ${currentBuild.fullDisplayName}",
                body: "The pipeline failed. Please check the Jenkins logs.",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
} 