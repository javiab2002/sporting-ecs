pipeline {
agent any
environment {
    DOCKER_IMAGE = "javiab2002/sporting-gijon"
}

stages {

    stage('Clonar repo') {
        steps {
            git 'https://github.com/javiab2002/sporting-ecs.git'
        }
    }

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
            sh 'terraform init'
            sh 'terraform apply -auto-approve'
        }
    }
}
}

