pipeline {
agent any

environment {
    DOCKER_IMAGE = "javiab2002/sporting-gijon"
}

stages {

    stage('Build Docker') {
        steps {
            dir('app') {
                sh 'docker build -t $DOCKER_IMAGE:v3 .'
            }
        }
    }

    stage('Login Docker Hub') {
        steps {
            withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                sh 'echo $PASS | docker login -u $USER --password-stdin'
            }
        }
    }

    stage('Push imagen') {
        steps {
            sh 'docker push $DOCKER_IMAGE:v3'
        }
    }

 
stage('Deploy Terraform') {
steps {
withCredentials([
string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY'),
string(credentialsId: 'aws-session-token', variable: 'AWS_SESSION_TOKEN')
]) {
sh '''
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
export AWS_DEFAULT_REGION=us-east-1
terraform init
terraform apply -auto-approve
'''
}
}
}



 }
}
